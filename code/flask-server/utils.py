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




# Ora random_opt_exams conterrà una lista di 5 elementi optExam con valori casuali per i campi.


