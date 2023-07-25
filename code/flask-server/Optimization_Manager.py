from firebase_admin import db
import pandas as pd
from utils import *
from optimizer import *
from datetime import datetime
import time





#FUNZIONA
def getDatabaseProblemData(sessionID):
    global status_list
    status_list.setProgress(sessionID, 'Gathering of data of Database Problem is running...')
    ref=db.reference('/')
    session_data = ref.child(sessionID).get()

    if not session_data:
        return None

    unavail_list = session_data.get('unavailList', {})
    print(unavail_list)

    # Convert each unavail instance from string to correct type
    for key,unavail in unavail_list.items():
        print(unavail)
        unavail['dates']=[datetime.fromisoformat(date_string) for date_string in unavail['dates']]
        unavail['type'] = int(unavail['type'])
        print(unavail['dates'])
        

    settings_data = session_data.get('settings', {})

    session_data = {
        "id": sessionID,
        "school": session_data.get('school'),
        "status": session_data.get('status'),
        "description": session_data.get('description'),
        "user": session_data.get('userID'),
        "startDate": datetime.strptime(session_data.get('startDate'), "%Y-%m-%dT%H:%M:%S"),
        "endDate": datetime.strptime(session_data.get('endDate'), "%Y-%m-%dT%H:%M:%S"),
        "unavailList": unavail_list,
        "settings": settings_data #session_data.get('semester'),
    }

    problem_session = ProblemSession(**session_data)

    return problem_session

#FUNZIONA
def getDatabaseExam(cds_id, sessionID, school, percentage):
    global status_list

    try:
        status_list.setProgress(sessionID, percentage + ' Recupero dei dati del Database Esami in corso...')
        # Leggi i dati dal foglio specificato del file Excel
        data = pd.read_excel('Database esami_'+school+'.xlsx', sheet_name=cds_id)
    except FileNotFoundError as e:
        status_list.setProgress(sessionID, percentage + ' File Excel non trovato: flask-server\Database esami_'+school+'.xlsx')
        #print('Errore:', e)
        return 'file error'
    except ValueError as e:
        status_list.setProgress(sessionID, percentage + f' Foglio "{cds_id}" non trovato nel file Excel.')
        #print('Errore:', e)
        return 'sheet error'

    # Creates an empty list for Exam objects
    resultsExams1 = []

    # Iterate on dataframe rows
    for _, row in data.iterrows():
        # Creates a dictionary for the data of the Exam object
        exam_data = {
            "cds": row['Cds'],
            "course_code": str(row['Course Code']),
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
        count=0
    # for ex in resultsExams1:
    #     count+=1
    #     print(f'{count}) {ex.toString()}')
        
    return resultsExams1

#FUNZIONA
def createOptExamList(ExamList, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Exam list creation is running...')
    # Creates an empty list for optExam objects
    resultsExams2 = []

    for exam in ExamList:
        optexam_data = {
            'cds': exam.cds,
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
            "timeWeight": 0,
            "minDistanceExams": [],
            "minDistanceCalls": [],
            "assignedDates": [],
        }
        # Create an optExam object using the data dictionary
        exam2 = optExam(**optexam_data)
        # Add the optExam object to the list
        resultsExams2.append(exam2)
        #print(type(exam2.professor))
    return resultsExams2


def createWeight(unprocessedExamList, semester, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Weight creation is running')
    # Creates weights for each optExam
    for exam in unprocessedExamList:
        exam.effortWeight = (exam.cfu * 3 + exam.passed_percentage * 4 + exam.average_mark * 4)/100
        exam.timeWeight = [int(2**(-0.3 * abs(exam.sem - exam_j.sem)) * 1000) / 100 + 10 * ((exam.sem == semester) * (exam_j.sem == semester)) for exam_j in unprocessedExamList]
        #exam.timeWeight = [int(2**(-0.3*abs(exam.sem - exam_j.exam.sem))*1000)/100 + 10*((exam.sem==semester).real)*((exam_j.exam.sem==semester).real) for exam_j in unprocessedExamList] 
    return unprocessedExamList  


def addDistances(unprocessedExamList, problem_session, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Distances adding is running...')

    if 'minDistanceCalls' in problem_session.settings and problem_session.settings['minDistanceCalls'].get('Exceptions') is not None:
        exceptions = problem_session.settings['minDistanceCalls']['Exceptions'].items()
    else:
        exceptions = []
    
   
    for opt_exam in unprocessedExamList:
        opt_exam.minDistanceExams = problem_session.settings['minDistanceExams']
        exception_found=False
        for k, value in exceptions:
            #print(f'addDistance: value: {value}')
            
            #print(f"addDistance: value.id type:{type(value['id'])}")
            #print(f"addDistance: optExam.coursecode:{type(opt_exam.course_code)}")
            #print(f"addDistance: optExam.coursecode:{opt_exam.course_code} == {value['id']}")
            if opt_exam.course_code == value['id']:
                #print(opt_exam.course_code)
                opt_exam.minDistanceCalls = int(value['distance'])
                exception_found=True
        if(not exception_found):
            opt_exam.minDistanceCalls = int(problem_session.settings['minDistanceCalls']['Default'])

    return unprocessedExamList

#TESTARE IL MATCHING DI DATE
def addUnavailability(unprocessedExamList, problem_session, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Unavailability merging is running...')
    for opt_exam in unprocessedExamList:
        professor_list = []
        print(opt_exam.professor)
        professors = opt_exam.professor.split('-')  #Divides the string into hyphenated names
        professor_list.extend(professors)  # Adds names to the professor_list
        print(professor_list)
        
        for k, value in problem_session.unavailList.items():
            print(f'{k} : {value}')
            

            if value['name'] in professor_list:
                opt_exam.unavailDates.extend(value['dates']) #qui carica una lista di liste, deve appendere solo gli elementi
                print(f'addUnavail:{opt_exam.unavailDates} list of: {type(opt_exam.unavailDates[0])}')
            if value['type']==1:
                print(f" aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa {value['dates']}")
                opt_exam.unavailDates.extend(value['dates'])
        # print('addUnavail: assegnazione indisponibilità')
        print(opt_exam.unavailDates)
    return unprocessedExamList


def runOptimizationManager(sessionID, callback):
    global status_list
    
    status_list.setProgress(sessionID, 'Optimization flow started')
    # Get according to sessionID database values Problem
    status_list.setProgress(sessionID, 'Gathering of data of Database Problem will start shortly')
    problem_session=getDatabaseProblemData(sessionID)
    status_list.setProgress(sessionID, 'Database Problem data gathering completed')
    #print(problem_session)
    ## Itera each school CdS
    if problem_session.school == 'Ing_Ind_Inf':
        cds_list = ['ATM','ELT']#, 'ELN', 'BIO', 'MTM', 'INF']
    if problem_session.school == 'Design':
        cds_list = ['ATM']#,'ELT', 'ELN', 'BIO', 'MTM', 'INF']
    if problem_session.school == 'AUIC':
        cds_list = ['ATM']#,'ELT', 'ELN', 'BIO', 'MTM', 'INF']

        
    resultsExams = set()
    
    for index, cds_id in enumerate(cds_list, 1):
        total_cds = len(cds_list)  # Numero totale di cds nella lista
        percentage = f"Iterazione {index}/{total_cds}: {cds_id}"
        status_list.setProgress(sessionID, percentage + ' Gathering of data of Database Exam will start shortly')
        ExamList = getDatabaseExam(cds_id, sessionID, problem_session.school, percentage)
        if ExamList=='file error':
            status_list.setProgress(sessionID, 'DATABASE NOT FOUND')
            return
        if ExamList == 'sheet error':
            status_list.setProgress(sessionID, 'SHEET NOT FOUND')
            return
        status_list.setProgress(sessionID, percentage + ' Database Problem data gathering completed')
        status_list.setProgress(sessionID, percentage + ' Exam list creation will start shortly')
        optExamList=createOptExamList(ExamList, sessionID, percentage)
        status_list.setProgress(sessionID, percentage + ' Exam list creation completed')
        unprocessedExamList=optExamList
       
        for item_i in unprocessedExamList:
             for item_j in resultsExams:
                 if item_i.course_code == item_j.course_code:
                        item_i.assignedDates = item_j.assignedDates
        
        status_list.setProgress(sessionID, percentage + ' Weight creation will start shortly')
        unprocessedExamList1=createWeight(unprocessedExamList, problem_session.settings['currSemester'], sessionID, percentage)
        status_list.setProgress(sessionID, percentage + ' Weight creation completed')
        
        status_list.setProgress(sessionID, percentage + ' Distances adding will start shortly')
        unprocessedExamList2=addDistances(unprocessedExamList1, problem_session, sessionID, percentage)
        status_list.setProgress(sessionID, percentage + ' Distances adding completed')
        
        
        status_list.setProgress(sessionID, percentage + ' Unavailability merging will start shortly')
        unprocessedExamList3=addUnavailability(unprocessedExamList2, problem_session, sessionID, percentage)
        status_list.setProgress(sessionID, percentage + ' Unavailability merging completed')

        status_list.setProgress(sessionID, percentage + ' Optimization process will start shortly')
        [result, scheduledExam]=solveScheduling(unprocessedExamList3, problem_session)
        print(scheduledExam[0].assignedDates)
        ### HO INSERITO DEL TEMPO NULLO PER RIUSCIRE A FAR PARTIRE UN ALTRO SCHEDULING E OTTENERE LA RISPOSTA
        time.sleep(5)
        if result == 1:
            status_list.setProgress(sessionID, percentage + ' Optimization process completed')
            status_list.setStatus(sessionID,'NOT SOLVED')
        if result == 0:
            results_course_codes = {exam.course_code for exam in resultsExams}
            for element in scheduledExam:
                if element.course_code in results_course_codes:
                    pass
                else:
                    resultsExams.add(element)
                    # print(element.toString())
            status_list.setProgress(sessionID, percentage + ' Optimization process completed')
    if result== 0:        
        status_list.setStatus(sessionID,'SOLVED')
        
        callback(resultsExams, problem_session)
