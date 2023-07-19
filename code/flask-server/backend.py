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


#cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")

json_file_path = "C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json"
cred_obj = firebase_admin.credentials.Certificate(json_file_path)


default_app = firebase_admin.initialize_app(cred_obj, {'databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'})

ref = db.reference("/") # Ottieni un riferimento al percorso del database dove desideri salvare i dati

status_data = {
       "flag": 'NOT STARTED',
       "status": [],
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
    status.setStatus('partito')
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
    stato_corrente = status.getStatus()

    # Restituisci la risposta HTTP al browser
    return stato_corrente

@app.route("/askFlag/<string:sessionID>")
def askFlag(sessionID):
    ## Ottieni l'oggetto status_obj da qualche parte, ad esempio passandolo come argomento
    flag_corrente = status.getFlag()

    # Restituisci la risposta HTTP al browser
    return flag_corrente

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
        problem_session = ProblemSession(**session_data)  # Create a ProblemSession object
        problem_sessions.append(problem_session)

    response = json.dumps([ps.__dict__ for ps in problem_sessions])  # Convert the list of ProblemSession objects to JSON
    return response

### IMPLEMENTED
@app.route("/getSessionData/<string:sessionID>")
def getSessionData(sessionID):
    #get per sessionID
    SessionData = ref.child(sessionID).get()
    print(SessionData)

    return SessionData

@app.route("/setSettings/<string:sessionID>/<string:distCalls>/<string:distExams>", methods=['POST'])
def setSettings(sessionID, distCalls, distExams):
    print(sessionID, distCalls, distExams)
    # Converti la data in formato stringa in un oggetto datetime
    distCallsObj = int(distCalls)
    distExamsObj = int(distExams)

    # Crea un nuovo nodo nel database con l'sessionID come chiave e la start_date come valore
    ref.child(sessionID).update({
        'startDate': distCallsObj,
        'endDate': distExamsObj
    })

    print('Sto salvando dati per: ' + sessionID)
    print(distCallsObj, type(distCallsObj))
    print(distExamsObj, type(distExamsObj))

    return 'Settings saved successfully.'

### IMPLEMENTED
@app.route("/saveUnavailability/", methods=['POST'])
def saveUnavailability():
    txt='unavailability'
    action='saved'
    request_data = request.get_json()
    
    date_list = request_data['dates'].split("/")
    date_obj_list = [datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f").isoformat() for date_str in date_list]

    unavail_node = ref.child(request_data['sessionID']).child('unavailList')

    if('unavailID' not in  request_data ):
        unavail_node = unavail_node.push()
        print(unavail_node.key)
    else:
        print(request_data['unavailID'])
        unavail_node = unavail_node.child(request_data['unavailID'])

    unavail_node.update({
        'name': request_data['name'],
        'type': request_data['type'],
        'dates': date_obj_list
    })

    #print('Sto salvando dati per: ' + sessionID)

    return {'status': f'{txt} {action} successfully.', 'id':unavail_node.key}

##IMPLEMENTED
@app.route("/delete_unavail/<string:sessionID>/<string:unavailID>")
def deleteUnavailability(sessionID, unavailID):

    # Elimina l'intero blocco "unavailID" dal database
    ref.child(sessionID).child('unavailList').child(unavailID).delete()
    
    return 'Unavailability deleted succesfully'

@app.route("/getProfessorList")
def getProfessorList():
    # Carica il file Excel
    df = pd.read_excel("C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\Database esami.xlsx")

    # Cerca l'indice della colonna in cui l'elemento della sua prima riga è la parola "Docenti"
    indice_docenti = df.columns.get_loc('Docenti')

    # Seleziona gli elementi dalla seconda riga in poi nella colonna "Docenti"
    elementi_docente = df.iloc[1:, indice_docenti].values.flatten()

    # Rimuovi gli elementi duplicati e spazi bianchi iniziali/finali
    elementi_unici = [docente.strip() for docente in elementi_docente if isinstance(docente, str)]
    elementi_unici = list(set(elementi_unici)).tolist()

    response = json.dumps(elementi_unici)  # Converti la lista in una stringa JSON
    return response

@app.route("/saveSession/",methods=['POST'])
def saveSession():
    txt='session'
    action='saved'
    request_data = request.get_json()

    if('sessionID' not in  request_data ):
        session_node = ref.push()
        print(session_node.key)
    else:
        print(request_data['sessionID'])
        session_node = ref.child(request_data['sessionID'])
        
    del request_data['sessionID']

    for key in request_data:
        print(key)
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
    
