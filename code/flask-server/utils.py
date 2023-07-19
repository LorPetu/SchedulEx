class Unavail:
    def __init__(self, id, type, dates, name):
        self.id = id
        self.type = type
        self.dates = dates
        self.name=name
        
class ProblemSession:
    def __init__(self, id, school, status, description, user,startDate, endDate, unavailList, settings, semester, callsNumber):
        self.id = id
        self.school = school
        self.status = status
        self.description = description
        self.user = user
        self.startDate = startDate
        self.endDate = endDate
        self.unavailList = unavailList
        self.settings = settings
        self.semester = semester
        self.callsNumber = callsNumber

class Exam:
    def __init__(self, school, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark):

        self.school = school
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

class optExam(Exam):
    def __init__(self, school, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark, unavailDates, effortWeight, timeWeight, minDistanceExams,minDistanceCalls, assignedDates):
        super().__init__(school, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark)
        self.unavailDates = unavailDates
        self.effortWeight = effortWeight
        self.timeWeight = timeWeight
        self.minDistanceExams = minDistanceExams
        self.minDistanceCalls = minDistanceCalls
        self.assignedDates = assignedDates
         
class optStatus:
    def __init__(self, flag, status, sessionID, ref):
        self.__flag = flag
        self.__status = status
        self.sessionID = sessionID
        self.ref = ref
    
    def getStatus(self)-> str:
        return self.__status
    def getFlag(self)-> str:
        return self.__flag

    def setStatus(self,new_status):
        self.__status=new_status
    def setFlag(self,new_flag):
        self.__flag=new_flag

if __name__ == "__main__":
    status=optStatus("NOT STARTED")

    print(status.getStatus())
    status.setStatus('STARTED')

    print(status.getStatus())

    
import random
from datetime import datetime

def create_random_optexams_list(size):
    professors = ['Professor A', 'Professor B', 'Professor C', 'Professor D']  # Example list of professors
    unavail_dates = [datetime(2023, 6, 1), datetime(2023, 6, 8), datetime(2023, 6, 15)]  # Example list of unavailable dates
    effort_weights = [1, 2, 3, 4, 5]  # Example list of effort weights
    assigned_dates = [None] * size  # Initialize with None values

    optexams_list = []
    for _ in range(size):
        sem = random.randint(1, 6)
        professor = random.choice(professors)

        exam = Exam(sem, professor)
        unavail_date = random.choices(unavail_dates, k=random.randint(1, len(unavail_dates)))
        effort_weight = random.choice(effort_weights)
        assigned_date = random.choices(assigned_dates, k=random.randint(1, len(assigned_dates)))

        optexams = optExam(exam, unavail_date, effort_weight, assigned_date)
        optexams_list.append(optexams)

    return optexams_list


