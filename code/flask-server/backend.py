# Import necessary libraries
import json
import os
from utils import *
from flask import Flask, request , send_file, jsonify
import firebase_admin
from datetime import datetime
from firebase_admin import db
import pandas as pd
from threading  import Thread
import openpyxl
from Optimization_Manager import *

# Initialize Firebase Admin SDK with the credentials
cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")
default_app = firebase_admin.initialize_app(cred_obj, {'appName':'SchedulEx','databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'})

app = Flask(__name__) # Create a Flask application
ref = db.reference("/") # Reference to the Firebase Realtime Database root

# Route to start the optimization process for a given sessionID
@app.route("/startOptimization/<string:sessionID>")
def startOptimization(sessionID):
    global status_list
    updatelist=[]
    sessionID_list= list(ref.get().keys())
    print(sessionID_list)
    for el in sessionID_list:
        status_data = {
       "progress": 'No progress yet',
       "status": ref.child(el).child('status').get(),
       "sessionID": el,
        }
        status = optStatus(**status_data)
        updatelist.append(status)
    status_list.list=updatelist
    StartedPresent=False

   # Checks whether the object with the same sessionID already exists in status_list.list
    for existing_status in status_list.list:
        if existing_status.getStatus() == "STARTED" and existing_status.sessionID != sessionID : 
            StartedPresent=True        
    if not StartedPresent:
            status_list.setStatus(sessionID,'STARTED')
            # Start optimisation for the existing session
            optimization_thread = Thread(target=runOptimizationManager, args=(sessionID, handleOptimizationResults))
            optimization_thread.start()
    else:
        status_list.setStatus(sessionID,'NOT STARTED')
        status_list.setProgress(sessionID, 'Another scheduling process is running. please wait until is finished.')
    
    return {'status': status_list.getStatus(sessionID), 'progress': status_list.getProgress(sessionID)}

# Callback function to handle optimization results
def handleOptimizationResults(results, problem_session):
    for element in results:
        element.assignedDates= [date.strftime("%Y-%m-%d") for date in element.assignedDates]
        element.unavailDates= [date.strftime("%Y-%m-%d") for date in element.unavailDates]
    
    # Callback function that will be called by the thread when it has completed the optimisation
    print('#### handleOptimization Results ####\n')
    for result in results:
        print(result.toString())
    
    # Creating the download folder if it does not exist
    download_folder = 'download'
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)

    # Saving the results list in JSON format
    json_data = [result.__dict__ for result in results]
    json_file_path = os.path.join(download_folder, f"Calendar_{problem_session.id}.json")
    with open(json_file_path, 'w') as json_file:
        json.dump(json_data, json_file)

    # Creating a new Excel file
    workbook = openpyxl.Workbook()
    sheet = workbook.active

    # Column header
    headers = ["Cds", "Course Code", "Course Name", "Semester", "Year", "Location", "Professor", "Section", "Date"]  # Sostituisci con i nomi dei campi di result
    sheet.append(headers)
    row_values = []
    for result in results:
        for date in result.assignedDates:
            row_values = [result.cds, result.course_code, result.course_name, result.semester, result.year, result.location, result.professor, result.section, date]
            sheet.append(row_values)
    
    # Saving the Excel file
    excel_file_path = os.path.join(download_folder, f"Calendar_{problem_session.id}.xlsx")
    workbook.save(excel_file_path)

# Route to get the status and progress of the optimization process for a given sessionID
@app.route("/askStatus/<string:sessionID>")
def askStatus(sessionID):
    global status_list
    if status_list.list ==[]:
        updatelist=[]
        sessionID_list= list(ref.get().keys())
        print(sessionID_list)
        for el in sessionID_list:
            status_data = {
        "progress": 'No progress yet',
        "status": ref.child(el).child('status').get(),
        "sessionID": el,
            }
            status = optStatus(**status_data)
            updatelist.append(status)
        status_list.list=updatelist
    
    return {'status': status_list.getStatus(sessionID), 'progress' : status_list.getProgress(sessionID)}

# Route to set the userID for a given sessionID
@app.route("/setUserID/<string:sessionID>/<string:userID>", methods=['POST'])
def setUserID(sessionID, userID):
    # Creates a new node in the database with sessionID as key 
    ref.child(sessionID).update({
        'userID': userID
    })

    return 'UserID saved successfully.'

# Route to set the start and end dates for a given sessionID
@app.route("/setStartEndDate/<string:sessionID>/<string:startDate>/<string:endDate>", methods=['POST'])
def setStartEndDate(sessionID, startDate, endDate):
    # Convert the date in string format to a datetime object
    startDateObj = datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S.%f")
    endtDateObj = datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S.%f")

    # Create a new node in the database with sessionID as the key and start_date as the value
    ref.child(sessionID).update({
        'startDate': startDateObj.isoformat(),  # Salva la data in formato ISO8601
        'endDate': endtDateObj.isoformat()
    })
    
    return 'Start date saved successfully.'

# Route to get a list of sessions
@app.route("/getSessionList")
def getSessionList():
    session_list = list(ref.get().keys()) if (ref.get()!=None) else []  

    problem_sessions = []
    for session_id in session_list:
        session_node= ref.child(session_id)
        session_data = {
            "id": session_id,
            "school": session_node.child('school').get(),
            "status": session_node.child('status').get(),
            "description": session_node.child('description').get(),
            "user": session_node.child('userID').get(),
            "startDate": session_node.child('startDate').get(),
            "endDate": session_node.child('endDate').get()
        }
        problem_sessions.append(session_data)

    response = json.dumps(problem_sessions)  # Convert the list of ProblemSession objects to JSON
    return response

# Route to get data for a specific session
@app.route("/getSessionData/<string:sessionID>")
def getSessionData(sessionID):
    SessionData = ref.child(sessionID).get()

    return SessionData

# Route to get unavailability data for a specific session and unavailability ID
@app.route("/getUnavailData/<string:sessionID>/<string:unavailID>")
def getUnavailabilityData(sessionID, unavailID):
    # Retrieve the Unavail data from the Firebase Realtime Database
    unavailData = ref.child(sessionID).child('unavailList').child(unavailID).get()

    # Check if the unavailData exists
    if unavailData!='':
        return unavailData
    else:
        # Return an empty response if the unavailData doesn't exist
        return {
            'type': 0,
            'name': '',
            'dates': []
        }

# Route to set settings for a specific session
@app.route("/setSettings/", methods=['POST'])
def setSettings():
    txt='settings'
    action='saved'
    request_data = request.get_json()
    settings_node = ref.child(request_data['sessionID']).child('settings')   

    flag=False

    if('minDistanceExams' in request_data): 
        settings_node.child('minDistanceExams').set(request_data['minDistanceExams'])
        flag=True
    if ('minDistanceCallsDefault' in request_data):
        settings_node.child('minDistanceCalls').child('Default').set(request_data['minDistanceCallsDefault'])
        flag=True
    if('numCalls' in request_data):
        settings_node.child('numCalls').set(request_data['numCalls'])
        flag=True
    if('currSemester' in request_data):
        settings_node.child('currSemester').set(request_data['currSemester'])   
        flag=True 
    if not flag:
        exceptions_node = settings_node.child('minDistanceCalls').child('Exceptions')
        exceptions =exceptions_node.get()
        del request_data['sessionID']
        exceptions_node.push().update(request_data)
        if(exceptions==None):
            exceptions=[]
        else:
            print(type(exceptions))

    return 'Settings saved successfully.'

# Route to save unavailability data for a specific session
@app.route("/saveUnavailability/", methods=['POST'])
def saveUnavailability():
    txt='unavailability'
    action='saved'
    request_data = request.get_json()
    
    unavail_node = ref.child(request_data['sessionID']).child('unavailList')

    if('unavailID' not in  request_data ):
        unavail_node = unavail_node.push()
    else:
        unavail_node = unavail_node.child(request_data['unavailID'])
        del request_data['unavailID']
    del request_data['sessionID']

    # Date check and modification  
    if('dates' in request_data):
        date_list = unavail_node.child('dates').get()
        if(date_list==None):
            date_list=[]
        for date_str in request_data['dates'].split("/"):
            currDate = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f").isoformat()
            if(currDate not in date_list):
                date_list.append(currDate)
        request_data['dates']= date_list

    if(request_data!={}): 
        unavail_node.update(
        request_data
    )

    return {'status': f'{txt} {action} successfully.','id': unavail_node.key, 'value':unavail_node.get()}

# Route to delete an unavailability block from a session
@app.route("/delete_unavail/<string:sessionID>/<string:unavailID>")
def deleteUnavailability(sessionID, unavailID):
    ref.child(sessionID).child('unavailList').child(unavailID).delete()
    
    return 'Unavailability deleted succesfully'

# Route to delete an unavailability date from a session
@app.route("/deleteUnavailabilityDate", methods=['POST'])
def deleteUnavailabilityDate():
    txt='unavailability'
    action='saved'
    request_data = request.get_json()
    unavail_node = ref.child(request_data['sessionID']).child('unavailList')
    unavail_node = unavail_node.child(request_data['unavailID'])

    if('date' in request_data):
        date_list = unavail_node.child('dates').get()
        if(date_list==None):
            date_list=[]
        
        
        date_list.remove( datetime.strptime(request_data['date'], "%Y-%m-%d %H:%M:%S.%f").isoformat())
        unavail_node.update({
            'dates': date_list
        })
        
    return 'date deleted'

# Route to get a list of professors
@app.route("/getProfessorList")
def getProfessorList():
    # Upload Excel file
    df = pd.read_excel('./Database esami_Ing_Ind_Inf.xlsx', sheet_name='total')

    # Look for the index of the column where the element in its first row is the word "Docenti".
    indice_docenti = df.columns.get_loc('Professor')

    # Select items from the second row onwards in the "Docenti" column
    elementi_docente = df.iloc[1:, indice_docenti].values.flatten()
    
    elementi_unici=[]
    for docente in elementi_docente:
        docente.strip()
        if('-' in docente):
            multi_professors = docente.split('-')
            for el in multi_professors:
                elementi_unici.append(el.strip())
        else:
            elementi_unici.append(docente)
    elementi_unici = list(set(elementi_unici))

    response = json.dumps(elementi_unici) 
    return elementi_unici

# Route to get a list of exams
@app.route("/getExamList")
def getExamList():
    df = pd.read_excel('./Database esami_Ing_Ind_Inf.xlsx', sheet_name='total')

    # Look for the index of the column where the element in its first row is the word "Docenti".
    indice_name = df.columns.get_loc('Course Name')
    indice_id = df.columns.get_loc('Course Code')

    # Select items from the second row onwards in the "Docenti" column
    exams_name = df.iloc[1:, indice_name].values.flatten()
    exams_id = df.iloc[1:, indice_id].values.flatten()

    results = [{'id': str(y), 'name': str(x)} for x, y in zip(exams_name, exams_id)]

    return results

# Route to save session data
@app.route("/saveSession/",methods=['POST'])
def saveSession():
    txt='session'
    action='saved'
    request_data = request.get_json()

    # Check if the sessionID is new or not
    if('sessionID' not in  request_data ):
        session_node = ref.push() # Create the new child for the corresponding sessionID
    else:
        session_node = ref.child(request_data['sessionID'])
        del request_data['sessionID']
        
    if(request_data!={}):
        session_node.update(request_data)
    
    return {'status': f'{txt} {action} successfully.', 'id':session_node.key}

# Route to delete a session
@app.route("/deleteSession/<string:sessionID>")
def deleteSession(sessionID):
    txt='session'
    action='delete'
    ref.child(sessionID).delete()

    return f'{txt} {sessionID} {action} successfully.'

# Route to download an Excel file with the optimization results
@app.route('/downloadExcel/<string:sessionID>')
def downloadExcel(sessionID):
    # For windows you need to use the drive name [ex: F:/Example.pdf]
    path = f"./download/Calendar_{sessionID}.xlsx"
    return send_file(path, as_attachment=True) # attachment_filename=f"Calendar_{sessionID}.xlsx")

# Route to get the JSON results of the optimization
@app.route('/getJSONresults/<string:sessionID>')
def getJSONresults(sessionID):
    # Get the path to the "download" folder in your Flask app
    download_folder = os.path.join(app.root_path, 'download')

    # Construct the path to the "data.json" file
    json_file_path = os.path.join(download_folder, f'Calendar_{sessionID}.json')

    # Check if the file exists
    if os.path.exists(json_file_path):
        # Read the JSON data from the file
        with open(json_file_path, 'r') as file:
            data = json.load(file)
            return jsonify(data)
    else:
        # Return a 404 Not Found response if the file doesn't exist
        return jsonify({'error': 'JSON data file not found'}), 404

# Run the Flask application in debug mode
if __name__== "__main__":
    app.run(debug=True)
    
