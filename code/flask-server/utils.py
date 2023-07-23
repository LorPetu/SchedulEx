from firebase_admin import db
import random
from datetime import datetime, timedelta



class Unavail:
    def __init__(self, id, type, dates, name):
        self.id = id
        self.type = type
        self.dates = dates
        self.name=name

    def toString(self):
        return f'{self.name} || {self.type} ||{self.dates}'
        
class ProblemSession:
    def __init__(self, id, school, status, description, user,startDate, endDate, unavailList, settings):
        self.id = id
        self.school = school
        self.status = status
        self.description = description
        self.user = user
        self.startDate = startDate
        self.endDate = endDate
        self.unavailList = unavailList
        self.settings = settings

class Exam:
    def __init__(self, cds, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark):

        self.cds = cds
        self.course_code = course_code
        self.me = me
        self.course_name = course_name
        self.semester = semester
        self.year = year
        self.sem = sem
        self.location = location
        self.exam_head = exam_head
        self.professor = professor
        self.section = section
        self.enrolled_number = enrolled_number
        self.cfu = cfu
        self.passed_percentage = passed_percentage
        self.average_mark = average_mark

    def toString(self):
        return f'{self.course_code} || {self.course_name}'

class optExam(Exam):
    def __init__(self, cds, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark, unavailDates, effortWeight, timeWeight, minDistanceExams,minDistanceCalls, assignedDates):
        super().__init__(cds, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark)
        self.unavailDates = unavailDates
        self.effortWeight = effortWeight
        self.timeWeight = timeWeight
        self.minDistanceExams = minDistanceExams
        self.minDistanceCalls = minDistanceCalls
        self.assignedDates = assignedDates

    def toString(self):
        return f'\n #### {self.course_code} || {self.course_name} ######\n ->Unavail Dates: {self.unavailDates}\n ->effortWeight: {self.effortWeight}\n ->timeWeights: {self.timeWeight}\n ->MinDistanceCalls: {self.minDistanceCalls}\n ->AssignedDates:{self.assignedDates}'    
         
class optStatus:
    def __init__(self, progress, status, sessionID):
        self.__progress = progress
        self.__status = status
        self.sessionID = sessionID
    
    def getStatus(self)-> str:
        return self.__status
    def getProgress(self)-> str:
        return self.__progress

    def setStatus(self,new_status):
        db.reference("/").child(self.sessionID).update({
        'status': new_status
    })
        self.__status=new_status
    def setProgress(self,progress_update):
        self.__progress=progress_update
    
    def toString(self):
        return f'status: {self.__status} || progress:{self.__progress} || id:{self.sessionID}'

class Sessions_status_list:
    def __init__(self, lst):
        for item in lst:
            if not isinstance(item, optStatus):
                raise ValueError("Each item in the list must be an instance of optStatus")
        self.list = lst

    def getStatus(self, sessionID) -> str:
        for item in self.list:
            if item.sessionID == sessionID:
                return item.getStatus()
        raise ValueError(f"No optStatus with sessionID '{sessionID}' found in the list.")

    def getProgress(self, sessionID) -> str:
        for item in self.list:
            if item.sessionID == sessionID:
                return item.getProgress()
        raise ValueError(f"No optStatus with sessionID '{sessionID}' found in the list.")

    def setStatus(self, sessionID, new_status):
        for item in self.list:
            if item.sessionID == sessionID:
                item.setStatus(new_status)
                return
        raise ValueError(f"No optStatus with sessionID '{sessionID}' found in the list.")

    def setProgress(self, sessionID, progress_update):
        for item in self.list:
            if item.sessionID == sessionID:
                item.setProgress(progress_update)
                return
        raise ValueError(f"No optStatus with sessionID '{sessionID}' found in the list.")
    
    def toString(self):
        printedString=''
        for item in self.list:
            printedString+=f'{item.toString()}\n' 
        return printedString

status_list=Sessions_status_list([])



