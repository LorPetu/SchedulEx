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



cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")


default_app = firebase_admin.initialize_app(cred_obj, {'appName':'SchedulEx','databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'})
app = Flask(__name__)

ref = db.reference("/")


### IMPLEMENTED
@app.route("/startOptimization/<string:sessionID>")
def startOptimization(sessionID):
    global status_list
    updatelist=[]
    sessionID_list= list(ref.get().keys())
    print(sessionID_list)
    for el in sessionID_list:
        # print(f' el in sessionID_LIST{el}')
        status_data = {
       "progress": 'No progress yet',
       "status": ref.child(el).child('status').get(),
       "sessionID": el,
        }
        status = optStatus(**status_data)
        updatelist.append(status)
    status_list.list=updatelist
    print('Status list is:\n')
    print(status_list.toString())

    StartedPresent=False

   # Controlla se l'oggetto con lo stesso sessionID è già presente in status_list.list
    for existing_status in status_list.list:
        if existing_status.getStatus() == "STARTED" and existing_status.sessionID != sessionID : 
            StartedPresent=True        
            
    print(StartedPresent)
    if not StartedPresent:
            status_list.setStatus(sessionID,'STARTED')
            # Avvia l'ottimizzazione per la sessione esistente
            optimization_thread = Thread(target=runOptimizationManager, args=(sessionID, handleOptimizationResults))
            optimization_thread.start()
            
    else:
        status_list.setStatus(sessionID,'NOT STARTED')
        status_list.setProgress(sessionID, 'Another scheduling process is running. please wait until is finished.')
    
    return {'status': status_list.getStatus(sessionID), 'progress': status_list.getProgress(sessionID)}
 



def handleOptimizationResults(results, problem_session):
    for element in results:
        print(type(element.assignedDates[0]))
        element.assignedDates= [date.strftime("%Y-%m-%d") for date in element.assignedDates]
        element.unavailDates= [date.strftime("%Y-%m-%d") for date in element.unavailDates]
    
    # Questa è la funzione di callback che verrà chiamata dal thread quando ha completato l'ottimizzazione
    print('#### handleOptimization Results ####\n')
    for result in results:
        print(result.toString())
    

    # Creazione della cartella download se non esiste
    download_folder = 'download'
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)

    # Salvataggio della lista results in formato JSON
    json_data = [result.__dict__ for result in results]
    json_file_path = os.path.join(download_folder, f"Calendar_{problem_session.id}.json")
    with open(json_file_path, 'w') as json_file:
        json.dump(json_data, json_file)

    
    # Creazione di un nuovo file Excel
    workbook = openpyxl.Workbook()
    sheet = workbook.active

    # Intestazione delle colonne
    headers = ["Cds", "Course Code", "Course Name", "Semester", "Year", "Location", "Professor", "Section", "Date"]  # Sostituisci con i nomi dei campi di result
    sheet.append(headers)
    row_values = []
    for result in results:
        for date in result.assignedDates:
            row_values = [result.cds, result.course_code, result.course_name, result.semester, result.year, result.location, result.professor, result.section, date]
            sheet.append(row_values)
        
        # Converti la lista in una stringa separata da virgole
        #row_values = [','.join(map(str, item)) if isinstance(item, list) else item for item in row_values]
        
    
    # Salvataggio del file Excel
    excel_file_path = os.path.join(download_folder, f"Calendar_{problem_session.id}.xlsx")
    workbook.save(excel_file_path)


@app.route("/askStatus/<string:sessionID>")
def askStatus(sessionID):
    global status_list
    if status_list.list ==[]:
        updatelist=[]
        sessionID_list= list(ref.get().keys())
        print(sessionID_list)
        for el in sessionID_list:
            # print(f' el in sessionID_LIST{el}')
            status_data = {
        "progress": 'No progress yet',
        "status": ref.child(el).child('status').get(),
        "sessionID": el,
            }
            status = optStatus(**status_data)
            updatelist.append(status)
        status_list.list=updatelist
    print(status_list.toString())
    
    ## Ottieni l'oggetto status_obj da qualche parte, ad esempio passandolo come argomento
    return {'status': status_list.getStatus(sessionID), 'progress' : status_list.getProgress(sessionID)}



### IMPLEMENTED
@app.route("/setUserID/<string:sessionID>/<string:userID>", methods=['POST'])
def setUserID(sessionID, userID):
    print(sessionID, userID)

    # Crea un nuovo nodo nel database con sessionID come chiave 
    ref.child(sessionID).update({
        'userID': userID
    })

    print(userID + 'for' + sessionID)

    return 'UserID saved successfully.'

### IMPLEMENTED
@app.route("/setStartEndDate/<string:sessionID>/<string:startDate>/<string:endDate>", methods=['POST'])
def setStartEndDate(sessionID, startDate, endDate):
    print(sessionID, startDate, endDate)
    # Converti la data in formato stringa in un oggetto datetime
    startDateObj = datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S.%f")
    endtDateObj = datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S.%f")

    # Crea un nuovo nodo nel database con sessionID come chiave e la start_date come valore
    ref.child(sessionID).update({
        'startDate': startDateObj.isoformat(),  # Salva la data in formato ISO8601
        'endDate': endtDateObj.isoformat()
    })

    #print(userID+' updates start end date for: '+ sessionID)
    print(startDateObj, type(startDateObj))
    print(endtDateObj, type(endtDateObj))
    
    return 'Start date saved successfully.'


### IMPLEMENTED
@app.route("/getSessionList")
def getSessionList():
    session_list = list(ref.get().keys()) if (ref.get()!=None) else []  # Get per sessionID

    problem_sessions = []
    for session_id in session_list:
        
        session_data = {
            "id": session_id,
            "school": ref.child(session_id).child('school').get(),
            "status": ref.child(session_id).child('status').get(),
            "description": ref.child(session_id).child('description').get(),
            "user": ref.child(session_id).child('userID').get(),
        }
        #problem_session = ProblemSession(**session_data)  # Create a ProblemSession object
        problem_sessions.append(session_data)

    response = json.dumps(problem_sessions)  # Convert the list of ProblemSession objects to JSON
    return response

### IMPLEMENTED
@app.route("/getSessionData/<string:sessionID>")
def getSessionData(sessionID):
    #get per sessionID
    SessionData = ref.child(sessionID).get()
    print(SessionData)

    return SessionData

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


@app.route("/setSettings/", methods=['POST'])
def setSettings():
    txt='settings'
    action='saved'
    request_data = request.get_json()
    print(request_data)
    settings_node = ref.child(request_data['sessionID']).child('settings')   

    flag=False

    if('minDistanceExams' in request_data): 
        # TO DO: 
        settings_node.child('minDistanceExams').set(request_data['minDistanceExams'])
        flag=True
    if ('minDistanceCallsDefault' in request_data):
        #TO DO:
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
        print(exceptions )
        del request_data['sessionID']
        exceptions_node.push().update(request_data)
        if(exceptions==None):
            exceptions=[]
        else:
            print(type(exceptions))

        #print('exceptions: ',exceptions_node.get())

        
        # for date_str in request_data['dates'].split("/"):
        #     currDate = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f").isoformat()
        #     if(currDate not in exceptions):
               
        #         exceptions.append(currDate)
#print(exceptions)
        


    return 'Settings saved successfully.'

### IMPLEMENTED
@app.route("/saveUnavailability/", methods=['POST'])
def saveUnavailability():
    txt='unavailability'
    action='saved'
    request_data = request.get_json()
    #print(request_data)
    

    unavail_node = ref.child(request_data['sessionID']).child('unavailList')

    if('unavailID' not in  request_data ):
        unavail_node = unavail_node.push()
        #print(unavail_node.key)
    else:
        #print(request_data['unavailID'])
        unavail_node = unavail_node.child(request_data['unavailID'])
        del request_data['unavailID']

    del request_data['sessionID']

    #date check and modification  
    if('dates' in request_data):
        date_list = unavail_node.child('dates').get()
        print(f'date list : {date_list}')
        if(date_list==None):
            date_list=[]
        
        
        for date_str in request_data['dates'].split("/"):
            currDate = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f").isoformat()
            if(currDate not in date_list):
                print('verified')
                date_list.append(currDate)
        print(date_list)
        request_data['dates']= date_list
    print('Save unavailability: request data = ', request_data)

    if(request_data!={}): 
        unavail_node.update(
        request_data
    )

    #print('Sto salvando dati per: ' + sessionID)

    return {'status': f'{txt} {action} successfully.','id': unavail_node.key, 'value':unavail_node.get()}

##IMPLEMENTED
@app.route("/delete_unavail/<string:sessionID>/<string:unavailID>")
def deleteUnavailability(sessionID, unavailID):

    # Elimina l'intero blocco "unavailID" dal database
    ref.child(sessionID).child('unavailList').child(unavailID).delete()
    
    return 'Unavailability deleted succesfully'

@app.route("/deleteUnavailabilityDate", methods=['POST'])
def deleteUnavailabilityDate():
    txt='unavailability'
    action='saved'
    request_data = request.get_json()
    unavail_node = ref.child(request_data['sessionID']).child('unavailList')
    unavail_node = unavail_node.child(request_data['unavailID'])

    if('date' in request_data):
        date_list = unavail_node.child('dates').get()
        print(f'date list : {date_list}')
        if(date_list==None):
            date_list=[]
        
        
        date_list.remove( datetime.strptime(request_data['date'], "%Y-%m-%d %H:%M:%S.%f").isoformat())
        print(f'date list : {date_list}')
        unavail_node.update({
            'dates': date_list
        })
        
    return 'date deleted'


@app.route("/getProfessorList")
def getProfessorList():
    # Carica il file Excel
    df = pd.read_excel('./Database esami_Ing_Ind_Inf.xlsx', sheet_name='total')

    # Cerca l'indice della colonna in cui l'elemento della sua prima riga è la parola "Docenti"
    indice_docenti = df.columns.get_loc('Professor')

    # Seleziona gli elementi dalla seconda riga in poi nella colonna "Docenti"
    elementi_docente = df.iloc[1:, indice_docenti].values.flatten()
    print(type(elementi_docente))
    
    elementi_unici=[]
    for docente in elementi_docente:
        docente.strip()
        if('-' in docente):
            multi_professors = docente.split('-')
            for el in multi_professors:
                elementi_unici.append(el.strip())
        else:
            elementi_unici.append(docente)
    print(elementi_unici)
    elementi_unici = list(set(elementi_unici))

    response = json.dumps(elementi_unici)  # Converti la lista in una stringa JSON
    return elementi_unici

@app.route("/getExamList")
def getExamList():
    # Carica il file Excel
    df = pd.read_excel('./Database esami_Ing_Ind_Inf.xlsx', sheet_name='total')

    # Cerca l'indice della colonna in cui l'elemento della sua prima riga è la parola "Docenti"
    indice_name = df.columns.get_loc('Course Name')
    indice_id = df.columns.get_loc('Course Code')

    # Seleziona gli elementi dalla seconda riga in poi nella colonna "Docenti"
    exams_name = df.iloc[1:, indice_name].values.flatten()
    exams_id = df.iloc[1:, indice_id].values.flatten()
    print(exams_name)
    print(exams_id)

    results = [{'id': str(y), 'name': str(x)} for x, y in zip(exams_name, exams_id)]

    print(results)
  # Converti la lista in una stringa JSON
    return results

@app.route("/saveSession/",methods=['POST'])
def saveSession():
    txt='session'
    action='saved'
    request_data = request.get_json()

    #Chech if the sessionID is new or not
    if('sessionID' not in  request_data ):
        session_node = ref.push() #create the new child for the corresponding sessionID
        print(session_node.key)
    else:
        print(request_data['sessionID'])
        session_node = ref.child(request_data['sessionID'])
        del request_data['sessionID']
        
    if(request_data!={}):
        session_node.update(request_data)
    

    return {'status': f'{txt} {action} successfully.', 'id':session_node.key}


@app.route("/deleteSession/<string:sessionID>")
def deleteSession(sessionID):
    txt='session'
    action='delete'
    #request_data = request.get_json()

    ref.child(sessionID).delete()


    return f'{txt} {sessionID} {action} successfully.'

@app.route('/downloadExcel/<string:sessionID>')
def downloadExcel(sessionID):
    # For windows you need to use the drive name [ex: F:/Example.pdf]
    path = f"./download/Calendar_{sessionID}.xlsx"
    return send_file(path, as_attachment=True) #attachment_filename=f"Calendar_{sessionID}.xlsx")

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

if __name__== "__main__":
    app.run(debug=True)
    
