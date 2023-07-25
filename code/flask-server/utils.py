# Import necessary modules
from firebase_admin import db
import random
from datetime import datetime, timedelta

# Define class Unavail to represent unavailable time slots for exams
class Unavail:
    def __init__(self, id, type, dates, name):
        self.id = id        # Unique identifier for the unavailability
        self.type = type    # Type of unavailability
        self.dates = dates  # List of specific dates when the unavailability occurs
        self.name=name      # Name of the unavailability

    def toString(self):
        return f'{self.name} || {self.type} ||{self.dates}'

# Define class ProblemSession to represent a session for exam scheduling and optimization               
class ProblemSession:
    def __init__(self, id, school, status, description, user,startDate, endDate, unavailList, settings):
        self.id = id                    # Unique identifier for the session
        self.school = school            # Name of the school
        self.status = status            # Status of the session
        self.description = description  # Description the problem session
        self.user = user                # User 
        self.startDate = startDate      # Start date of the session
        self.endDate = endDate          # End date of the session
        self.unavailList = unavailList  # List of Unavail objects representing unavailable time slots for exams
        self.settings = settings        # Setting of min distances between exams/calls

# Define class Exam to represent an individual exam
class Exam:
    def __init__(self, cds, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark):
        self.cds = cds                                  # Study Programme 
        self.course_code = course_code                  # Code of the course
        self.me = me                                    # Mandatory or elective exam
        self.course_name = course_name                  # Course name
        self.semester = semester                        # Semester of the course
        self.year = year                                # Year of the course
        self.sem = sem                                  # Semester+year, 1,2,3,4,5,6
        self.location = location                        # Campus
        self.exam_head = exam_head                      # Head of the exam
        self.professor = professor                      # Professors of the exam
        self.section = section                          # Sections
        self.enrolled_number = enrolled_number          # Enroled number of students
        self.cfu = cfu                                  # CFU                    
        self.passed_percentage = passed_percentage      # Percentage of passed students
        self.average_mark = average_mark                # Average mark of the passed students            

    def toString(self):
        return f'{self.course_code} || {self.course_name}'

# Define class optExam as a subclass of Exam, representing an optimized exam with additional details
class optExam(Exam):
    def __init__(self, cds, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark, unavailDates, effortWeight, timeWeight, minDistanceExams,minDistanceCalls, assignedDates):
        super().__init__(cds, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark)
        self.unavailDates = unavailDates            # List of dates that are unavailable for scheduling the exam
        self.effortWeight = effortWeight            # Weight associated with the effort required for the exam
        self.timeWeight = timeWeight                # Weight associated with the scheduling time of the exam
        self.minDistanceExams = minDistanceExams    # Minimum distance between exams (in terms of time)
        self.minDistanceCalls = minDistanceCalls    # Minimum distance between exam calls 
        self.assignedDates = assignedDates          # Dates when the exam is scheduled

    def toString(self):
        return f'\n #### {self.course_code} || {self.course_name} ######\n ->Unavail Dates: {self.unavailDates}\n ->effortWeight: {self.effortWeight}\n ->timeWeights: {self.timeWeight}\n ->MinDistanceCalls: {self.minDistanceCalls}\n ->AssignedDates:{self.assignedDates}'    

# Define class optStatus to represent the status and progress of an optimization session                  
class optStatus:
    def __init__(self, progress, status, sessionID):
        self.__progress = progress      # Track the progress of the session
        self.__status = status          # Hold the status of the session
        self.sessionID = sessionID      # Unique identifier for the optimization session
    
    # Getter methods to retrieve progress and status
    def getStatus(self)-> str:
        return self.__status
    def getProgress(self)-> str:
        return self.__progress

    # Setter methods to update status in the Firebase database and progress
    def setStatus(self,new_status):
        db.reference("/").child(self.sessionID).update({
        'status': new_status
    })
        self.__status=new_status
    def setProgress(self,progress_update):
        self.__progress=progress_update
    
    def toString(self):
        return f'status: {self.__status} || progress:{self.__progress} || id:{self.sessionID}'

# Define class Sessions_status_list to manage a list of optStatus objects
class Sessions_status_list:
    def __init__(self, lst):
        for item in lst:
            if not isinstance(item, optStatus):
                raise ValueError("Each item in the list must be an instance of optStatus")
        self.list = lst

    # Methods to retrieve status and progress using sessionID
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

    # Methods to update status and progress using sessionID
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

# Create an empty Sessions_status_list object named status_list to manage optimization session statuses
status_list=Sessions_status_list([])



