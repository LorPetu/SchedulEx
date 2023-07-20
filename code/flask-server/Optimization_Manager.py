from firebase_admin import db
import pandas as pd
from utils import *

#FUNZIONA
def getDatabaseProblemData(sessionID, ref, status_obj):
    status_obj.setStatus('Gathering of data of Database Problem is running...')
    
    session_data = ref.child(sessionID).get()

    if not session_data:
        return None

    unavail_list = session_data.get('unavailList', {})
    settings_data = session_data.get('settings', {})
    min_distance_exams = settings_data.get('minDistanceExams')
    min_distance_calls_default = settings_data.get('minDistanceCalls', {}).get('Default')
    exceptions = settings_data.get('minDistanceCalls', {}).get('Exceptions', {})

    settings_list = [min_distance_exams, min_distance_calls_default]

    for key, value in exceptions.items():
        settings_list.append([key, value])

    result_list = [[item.get('name'), item.get('type'), item.get('dates', [])] for item in unavail_list.values()]

    session_data = {
        "id": sessionID,
        "school": session_data.get('school'),
        "status": session_data.get('status'),
        "description": session_data.get('description'),
        "user": session_data.get('userID'),
        "startDate": [],#session_data.get('startDate'),
        "endDate": [],#session_data.get('endDate'),
        "unavailList": result_list,
        "settings": settings_list,
        "semester": [],#session_data.get('semester'),
        "callsNumber": [],#session_data.get('callsNumber'),
    }

    problem_session = ProblemSession(**session_data)

    return problem_session

#FUNZIONA
def getDatabaseExam(cds_id, status_obj, school, percentage):
    
    try:
        status_obj.setStatus(percentage + ' Gathering of data of Database Exam is running...')
        # Read data from the specified sheet of the Excel file
        data = pd.read_excel('flask-server\Database esami_'+school+'.xlsx', sheet_name=cds_id)
    except FileNotFoundError:
        status_obj.setStatus(percentage + ' Excel file not found: flask-server\Database esami_'+school+'.xlsx')
        return None
    except ValueError:
        status_obj.setStatus(percentage + f' Sheet "{cds_id}" not found in the Excel file.')
        return None

    # Creates an empty list for Exam objects
    resultsExams1 = []

    # Iterate on dataframe rows
    for _, row in data.iterrows():
        # Creates a dictionary for the data of the Exam object
        exam_data = {
            "school": row['School'],
            "course_code": row['Course Code'],
            "me": row['M/E'],
            "course_name": row['Course Name'],
            "semester": row['Semester'],
            "year": row['Year'],
            "sem": row['SEM'],
            "location": row['Location'],
            "exam_head": row['Exam Head'],
            "professor": row['Professor'],
            "section": row['Section'],
            "enrolled_number": row['Enrolled number'],
            "cfu": row['CFU'], 
            "passed_percentage": row['Passed %'],
            "average_mark": row['Average Mark'],
        }
        # Create an Exam object using the data dictionary
        exam1 = Exam(**exam_data)
        # Add the Exam object to the list
        resultsExams1.append(exam1)
        #print(type(exam1.professor))
    return resultsExams1

#FUNZIONA
def createOptExamList(ExamList, status_obj, percentage):
    status_obj.setStatus(percentage + ' Exam list creation is running...')
    # Creates an empty list for optExam objects
    resultsExams2 = []

    for exam in ExamList:
        optexam_data = {
            "school": exam.school,
            "course_code": exam.course_code,
            "me": exam.me,
            "course_name": exam.course_name,
            "semester": exam.semester,
            "year": exam.year,
            "sem": exam.sem,
            "location": exam.location,
            "exam_head": exam.exam_head,
            "professor": exam.professor,
            "section": exam.section,
            "enrolled_number": exam.enrolled_number,
            "cfu": exam.cfu,
            "passed_percentage": exam.passed_percentage,
            "average_mark": exam.average_mark,
            "unavailDates": [],
            "effortWeight": 0,
            "timeWeight": [],
            "minDistanceExams": 0,
            "minDistanceCalls": [],
            "assignedDates": [],
        }
        # Create an optExam object using the data dictionary
        exam2 = optExam(**optexam_data)
        # Add the optExam object to the list
        resultsExams2.append(exam2)
        #print(type(exam2.professor))
    return resultsExams2


def createWeight(unprocessedExamList, semester, status_obj, percentage):
    status_obj.setStatus(percentage + ' Weight creation is running')
    # Creates weights for each optExam
    # for exam in unprocessedExamList:
    #     exam.effortWeight = exam.cfu * 3 + exam.passed_percentage * 4 + exam.average_mark * 4
    #     exam.timeWeight = [int(2**(-0.3*abs(exam.sem - exam_j.exam.sem))*1000)/100 + 10*((exam.sem==semester).real)*((exam_j.exam.sem==semester).real) for exam_j in unprocessedExamList] 
    return unprocessedExamList  


def addDistances(unprocessedExamList, problem_session, status_obj, percentage):
    status_obj.setStatus(percentage + ' Distances adding is running...')
    for opt_exam in unprocessedExamList:
        opt_exam.minDistanceExams = problem_session.settings[0]
        for i in range(2, len(problem_session.settings)):
            setting = problem_session.settings[i]
            if int(setting[0]) == opt_exam.course_code:
                opt_exam.minDistanceCalls = int(setting[1])
                break
            else:
                opt_exam.minDistanceCalls = int(problem_session.settings[1])
    return unprocessedExamList

#TESTARE IL MATCHING DI DATE
def addUnavailability(unprocessedExamList, problem_session, status_obj, percentage):
    status_obj.setStatus(percentage + ' Unavailability merging is running...')

    professor_list = []
    professors = opt_exam.professor.split('-')  #Divides the string into hyphenated names
    professor_list.extend(professors)  # Adds names to the professor_list
    #print(professor_list)

    for opt_exam in unprocessedExamList:
        # for each unavail {id, name, type, dates} in problem_session that is considered 
        # check if the unavail involves the professor of opt_exam 
        for unavail in problem_session.unavailList:
            if (unavail.name in opt_exam.professor):
                opt_exam.unavailDates += unavail.dates
            # if sublist[1] == 0:
            #     opt_exam.unavailDates += sublist[2]
            # elif sublist[1] == 1 and sublist[0] in professor_list:
            #     opt_exam.unavailDates += sublist[2]

    return unprocessedExamList


def runOptimizationManager(status_obj, callback):
    status_obj.setFlag(1)
    sessionID = status_obj.sessionID
    status_obj.setStatus('Optimization flow started')
    ref=status_obj.ref
    # Get according to sessionID database values Problem
    status_obj.setStatus('Gathering of data of Database Problem will start shortly')
    problem_session=getDatabaseProblemData(sessionID, ref, status_obj)
    status_obj.setStatus('Database Problem data gathering completed')
    #print(problem_session)
    ## Itera each school CdS
    if problem_session.school == 'Ing_Ind_Inf':
        cds_list = ['ATM']#,'ELT', 'ELN', 'BIO', 'MTM', 'INF']
    if problem_session.school == 'Design':
        cds_list = ['ATM']#,'ELT', 'ELN', 'BIO', 'MTM', 'INF']
    if problem_session.school == 'AUIC':
        cds_list = ['ATM']#,'ELT', 'ELN', 'BIO', 'MTM', 'INF']
    resultsExams = set()
    for index, cds_id in enumerate(cds_list, 1):
        total_cds = len(cds_list)  # Numero totale di cds nella lista
        percentage = f"Iterazione {index}/{total_cds}: {cds_id}"
        status_obj.setStatus(percentage + ' Gathering of data of Database Exam will start shortly')
        try:
            ExamList = getDatabaseExam(cds_id, status_obj, problem_session.school, percentage)
        except FileNotFoundError:
            status_obj.setFlag(0)
            break
        except ValueError:
            status_obj.setFlag(0)
            break
        status_obj.setStatus(percentage + ' Database Problem data gathering completed')
        status_obj.setStatus(percentage + ' Exam list creation will start shortly')
        optExamList=createOptExamList(ExamList, status_obj, percentage)
        status_obj.setStatus(percentage + ' Exam list creation completed')
        unprocessedExamList=optExamList
        for index1 in unprocessedExamList:
             for index2 in resultsExams:
                 if index1.course_code == index2.course_code:
                     index1.assignedDates = index2.assignedDates
        status_obj.setStatus(percentage + ' Weight creation will start shortly')
        unprocessedExamList1=createWeight(unprocessedExamList, problem_session.semester, status_obj, percentage)
        status_obj.setStatus(percentage + ' Weight creation completed')
        status_obj.setStatus(percentage + ' Distances adding will start shortly')
        unprocessedExamList2=addDistances(unprocessedExamList1, problem_session, status_obj, percentage)
        status_obj.setStatus(percentage + ' Distances adding completed')
        status_obj.setStatus(percentage + ' Unavailability merging will start shortly')
        unprocessedExamList3=addUnavailability(unprocessedExamList2, problem_session, status_obj, percentage)
        status_obj.setStatus(percentage + ' Unavailability merging completed')
        print(unprocessedExamList3[0].minDistanceCalls)
        #print(unprocessedExamList3[1].effortWeight)
        #status_obj.setStatus(percentage + ' Optimization process will start shortly')
        #resultsExams.add(startOptimization(unprocessedExamList3))
        #status_obj.setStatus(percentage + ' Optimization process completed')
        
        unprocessedExamList3[1].assignedDates=['2023-06-02', '2023-06-03']
        resultsExams.add(unprocessedExamList3[1])
        callback(resultsExams)
        status_obj.setFlag(0) # 0 se ha finito e può partire un'altra ottimizzazione
    return resultsExams

#if __name__== "__main__":
#    runOptimizationManager('-N_TlgwdCqeEONkrZdPM')
 ## Ottieni esami del CdS list semplice
            #-> get al database exam per CdS 

            #-> per ognuno crea optExam(exam: exam, altri campi inizializzati vuoti)
            #-> List<optExam> unprocessedExams = list.map(value=optExam(exam:value, ))

        ## iter ogni exam di unprocessedExams 
            ## if (exam in resultsExams) verifica codice insegnamento
                #-> aggiorno l'elemento exam con resultExams[index] (elemnto trovato)
            ## else
                ## build unavailDates and update on exam
                    #-> 
                ## build effortWeight
                    #-> call weightBuilder
        
        ## resultExams.add(startOptimization(unprocessedList)) aggiungo al set gli elementi unici non schedulati precedentemente

    ## Alla fine di tutti i CdS converto il risultato finale resultExams in json
        ## aggiungo il json al Database problem in 'results': per il relativo sessionID
