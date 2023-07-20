import random
from datetime import datetime, timedelta

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

class optExam(Exam):
    def __init__(self, school, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark, unavailDates, effortWeight, timeWeight, minDistanceExams,minDistanceCalls, assignedDates):
        super().__init__(school, course_code, me, course_name, semester, year, sem, location, exam_head, professor, section, enrolled_number, cfu, passed_percentage, average_mark)
        self.unavailDates = unavailDates
        self.effortWeight = effortWeight
        self.timeWeight = timeWeight
        self.minDistanceExams = minDistanceExams
        self.minDistanceCalls = minDistanceCalls
        self.assignedDates = assignedDates

# # Generazione casuale di 5 oggetti optExam
# def generate_random_date():
#     start_date = datetime(2023, 7, 1)
#     end_date = datetime(2023, 12, 31)
#     random_days = random.randint(1, (end_date - start_date).days)
#     return start_date + timedelta(days=random_days)

# random_opt_exams = []
# for _ in range(5):
#     exam = optExam(
#         school="School" + str(random.randint(1, 10)),
#         course_code="C" + str(random.randint(100, 999)),
#         me="ME" + str(random.randint(1, 5)),
#         course_name="Course " + str(random.randint(1, 10)),
#         semester=random.randint(1, 2),
#         year=random.randint(2022, 2023),
#         sem=random.randint(1, 2),
#         location="Location " + str(random.randint(1, 5)),
#         exam_head="Head " + str(random.randint(1, 3)),
#         professor="Professor " + str(random.randint(1, 5)),
#         section="Section " + str(random.randint(1, 3)),
#         enrolled_number=random.randint(30, 100),
#         cfu=random.randint(6, 12),
#         passed_percentage=random.uniform(60, 100),
#         average_mark=random.uniform(18, 30),
#         unavailDates=[generate_random_date() for _ in range(random.randint(1, 5))],
#         effortWeight=random.uniform(1, 5),
#         timeWeight=random.uniform(0.5, 2),
#         minDistanceExams=random.randint(1, 10),
#         minDistanceCalls=random.randint(1, 5),
#         assignedDates=[generate_random_date() for _ in range(random.randint(1, 10))]
#     )
#     random_opt_exams.append(exam)

# Ora random_opt_exams conterrà una lista di 5 elementi optExam con valori casuali per i campi.