class Unavail:
    def __init__(self, id, type, dates, name):
        self.id = id
        self.type = type
        self.dates = dates
        self.name=name
        
class ProblemSession:
    def __init__(self,id,school,status,description,user):
        self.id =id
        self.school=school
        self.status=status
        self.description=description
        self.user=user


class Exam:
    def __init__(self, sem, professor):
        self.sem = sem
        self.professor = professor

class optExam:
    def __init__(self,exam,unavailDates,effortWeight,assignedDates):
        self.exam=exam
        self.unavailDates=unavailDates
        self.effortWeight=effortWeight
        self.assignedDates=assignedDates
         

class optStatus:
    def __init__(self, status, sessionID):
        self.__status = status
        self.sessionID = sessionID
    
    def getStatus(self)-> str:
        return self.__status

    def setStatus(self,new_status):
        self.__status=new_status

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


