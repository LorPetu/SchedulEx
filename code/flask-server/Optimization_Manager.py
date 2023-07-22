# Import necessary modules
from firebase_admin import db
import pandas as pd
from utils import *
from optimizer import *
from datetime import datetime
import time

# Function to retrieve data of a specific problem session from the Firebase database
def getDatabaseProblemData(sessionID):
    global status_list
    status_list.setProgress(sessionID, 'Gathering of data of Database Problem is running...')
    
    # Access the Firebase database and get the data for the given sessionID
    ref=db.reference('/')
    session_data = ref.child(sessionID).get()

    # If no data is found, return None
    if not session_data:
        return None

    # Extract unavailable dates from the session data using key 'dates'
    unavail_list = session_data.get('unavailList', {})
    dates_dict = unavail_list.get(sessionID, {}).get('dates', {})
    # Conversion of dates from string to datetime object
    datetime_list = [datetime.fromisoformat(date_string) for date_string in dates_dict.values()]

    # Extract and format relevant data for the problem session
    settings_data = session_data.get('settings', {})
    print('Settings data:\n',settings_data)
    session_data = {
        "id": sessionID,
        "school": session_data.get('school'),
        "status": session_data.get('status'),
        "description": session_data.get('description'),
        "user": session_data.get('userID'),
        "startDate": datetime.strptime(session_data.get('startDate'), "%Y-%m-%dT%H:%M:%S"),
        "endDate": datetime.strptime(session_data.get('endDate'), "%Y-%m-%dT%H:%M:%S"),
        "unavailList": datetime_list,
        "settings": settings_data #session_data.get('semester'),
    }
    # Create a ProblemSession object using the extracted data
    problem_session = ProblemSession(**session_data)

    return problem_session

# Function to retrieve exam data from the Excel file based on school and study course code
def getDatabaseExam(cds_id, sessionID, school, percentage):
    global status_list

    try:
        status_list.setProgress(sessionID, percentage + ' Recupero dei dati del Database Esami in corso...')
        # Read data from the specified sheet of the Excel file
        data = pd.read_excel('Database esami_'+school+'.xlsx', sheet_name=cds_id)
    except FileNotFoundError as e:
        status_list.setProgress(sessionID, percentage + ' File Excel non trovato: flask-server\Database esami_'+school+'.xlsx')
        #print('Errore:', e)
        return 'file error'
    except ValueError as e:
        status_list.setProgress(sessionID, percentage + f' Foglio "{cds_id}" non trovato nel file Excel.')
        #print('Errore:', e)
        return 'sheet error'

    # Create an empty list to hold Exam objects
    resultsExams1 = []

    # Iterate over dataframe rows to create Exam objects and add them to the list
    for _, row in data.iterrows():
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
        count=0
        
    return resultsExams1

# Function to create a list of optExam objects for optimization
def createOptExamList(ExamList, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Exam list creation is running...')
    # Create an empty list to hold optExam objects
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

    return resultsExams2

# Function to calculate effortWeight and timeWeight for each optExam object
def createWeight(unprocessedExamList, semester, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Weight creation is running')
    # Creates weights for each optExam
    for exam in unprocessedExamList:
        # Calculate effortWeight based on exam attributes
        exam.effortWeight = (exam.cfu * 3 + exam.passed_percentage * 4 + exam.average_mark * 4)/100
         # Calculate timeWeight for each pair of exams in the list
        exam.timeWeight = [int(2**(-0.3 * abs(exam.sem - exam_j.sem)) * 1000) / 100 + 10 * ((exam.sem == semester) * (exam_j.sem == semester)) for exam_j in unprocessedExamList]
        
    return unprocessedExamList  

# Function to add information about minimum distances to each optExam object
def addDistances(unprocessedExamList, problem_session, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Distances adding is running...')

    # Check for exceptions in the problem session settings
    if 'minDistanceCalls' in problem_session.settings and problem_session.settings['minDistanceCalls'].get('Exceptions') is not None:
        exceptions = problem_session.settings['minDistanceCalls']['Exceptions'].items()
    else:
        exceptions = []
   
    for opt_exam in unprocessedExamList:
        opt_exam.minDistanceExams = problem_session.settings['minDistanceExams']
        exception_found=False
        for k, value in exceptions:
            if opt_exam.course_code == value['id']:
                opt_exam.minDistanceCalls = int(value['distance'])
                exception_found=True
        if(not exception_found):
            opt_exam.minDistanceCalls = int(problem_session.settings['minDistanceCalls']['Default'])

    return unprocessedExamList

# Function to merge unavailability data with each optExam object
def addUnavailability(unprocessedExamList, problem_session, sessionID, percentage):
    global status_list
    status_list.setProgress(sessionID, percentage + ' Unavailability merging is running...')
    for opt_exam in unprocessedExamList:
        professor_list = []
        professors = opt_exam.professor.split('-')  # Split professor names separated by hyphen
        professor_list.extend(professors)           # Add names to the professor_list

        for k, value in problem_session.unavailList:
            if value['name'] in professor_list:
                opt_exam.unavailDates.append(value['dates']) # Append unavailability dates of professors
            if value['type']==1:
                opt_exam.unavailDates.append(value['dates']) # Append other unavailability dates

    return unprocessedExamList

# Function to manage the overall optimization process
def runOptimizationManager(sessionID, callback):
    global status_list
    
    status_list.setProgress(sessionID, 'Optimization flow started')
    # Get problem session data from the database
    status_list.setProgress(sessionID, 'Gathering of data of Database Problem will start shortly')
    problem_session=getDatabaseProblemData(sessionID)
    status_list.setProgress(sessionID, 'Database Problem data gathering completed')
    
    # List of CdS for different schools
    if problem_session.school == 'Ing_Ind_Inf':
        cds_list = ['ATM','ELT']#, 'ELN', 'BIO', 'MTM', 'INF']
    if problem_session.school == 'Design':
        cds_list = ['']
    if problem_session.school == 'AUIC':
        cds_list = ['']

    resultsExams = set()
    
    # Iterate over each school CdS and perform optimization
    for index, cds_id in enumerate(cds_list, 1):
        total_cds = len(cds_list)  # Total number of CdS in the list
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
       
        # Update assignedDates of exams that are already scheduled
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

        time.sleep(5)  # Time to allow starting another scheduling and obtaining the response
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
            status_list.setProgress(sessionID, percentage + ' Optimization process completed')
    if result== 0:        
        status_list.setStatus(sessionID,'SOLVED')

        # Call the callback function with the resultsExams and problem_session as arguments        
        callback(resultsExams, problem_session)
