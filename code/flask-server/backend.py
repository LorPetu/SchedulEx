import json
from utils import *
from flask import Flask, request
import firebase_admin
from datetime import datetime
from firebase_admin import db
import pandas as pd
from threading  import Thread
from Optimization_Manager import *
from queueManager import flag_queue


cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")

# json_file_path = "C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json"
# cred_obj = firebase_admin.credentials.Certificate(json_file_path)


default_app = firebase_admin.initialize_app(cred_obj, {'databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'})

ref = db.reference("/") 

status_data = {
       "progress": 'No progress yet',
       "status": '',
       "sessionID": [],
       "ref": [], 
    }
    # Create an Exam object using the data dictionary
status = optStatus(**status_data)
print(status)


app = Flask(__name__)

@app.route("/test")
def test():
    print('test ok')
    return 'test'

### IMPLEMENTED
@app.route("/startOptimization/<string:sessionID>")
def startOptimization(sessionID):
    status.setStatus('STARTED')
    status.sessionID = sessionID
    status.ref = ref

    # Crea un oggetto thread e passa gli argomenti come argomenti posizionali
    optimization_thread = Thread(target=runOptimizationManager, args=(status, handleOptimizationResults))

    optimization_thread.start()
    return 'Start process'

def handleOptimizationResults(results):
    # Questa è la funzione di callback che verrà chiamata dal thread quando ha completato l'ottimizzazione
    for result in results:
        print("Risultati dell'ottimizzazione:", result.assignedDates)
    
    import openpyxl

    # Creazione di un nuovo file Excel
    workbook = openpyxl.Workbook()
    sheet = workbook.active

    # Intestazione delle colonne
    headers = ["Corso", "Date Esame"]  # Sostituisci con i nomi dei campi di result
    sheet.append(headers)

    for result in results:
        row_values = [result.course_code, result.assignedDates]  # Sostituisci con i nomi dei campi corretti di result
        # Converti la lista in una stringa separata da virgole
        row_values = [','.join(map(str, item)) if isinstance(item, list) else item for item in row_values]
        
        sheet.append(row_values)

    # Salvataggio del file Excel
    workbook.save("flask-server\calendario.xlsx")


@app.route("/askStatus/<string:sessionID>")
def askStatus(sessionID):
    ## Ottieni l'oggetto status_obj da qualche parte, ad esempio passandolo come argomento
    result = {'status': status.getStatus(), 'progress' : status.getProgress()}
    

    # Restituisci la risposta HTTP al browser
    return result

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
    session_list = list(ref.get().keys())  # Get per sessionID

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

    if('minDistanceExam' in request_data): 
        # TO DO: 
        settings_node.child('minDistanceExam').set(request_data['minDistanceExam'])
        flag=True
    if ('minDistanceCalls' in request_data):
        #TO DO:
        settings_node.child('minDistanceCalls').child('Default').set(request_data['minDistanceCalls'])
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
    print(request_data)
    

    unavail_node = ref.child(request_data['sessionID']).child('unavailList')

    if('unavailID' not in  request_data ):
        unavail_node = unavail_node.push()
        print(unavail_node.key)
    else:
        print(request_data['unavailID'])
        unavail_node = unavail_node.child(request_data['unavailID'])
        del request_data['unavailID']

    del request_data['sessionID']

    if('dates' in request_data):
        date_list = request_data['dates'].split("/")
        date_obj_list = [datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f").isoformat() for date_str in date_list]
        request_data['dates']= date_obj_list
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

@app.route("/getProfessorList")
def getProfessorList():
    # Carica il file Excel
    df = pd.read_excel('./Database esami_modificato.xlsx')

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
    df = pd.read_excel('./Database esami_modificato.xlsx')

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
        print('sto qua')
        session_node.update(request_data)
    

    return {'status': f'{txt} {action} successfully.', 'id':session_node.key}


@app.route("/deleteSession/<string:sessionID>")
def deleteSession(sessionID):
    txt='session'
    action='delete'
    #request_data = request.get_json()

    ref.child(sessionID).delete()


    return f'{txt} {sessionID} {action} successfully.'


if __name__== "__main__":
    app.run(debug=True)
    
