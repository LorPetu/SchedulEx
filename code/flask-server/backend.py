import json
from flask import Flask, jsonify
import firebase_admin
from datetime import datetime
from firebase_admin import db
# from threading import Thread
import os
import pandas as pd

# import Optimization_Manager

cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")

#json_file_path = "C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json"
#cred_obj = firebase_admin.credentials.Certificate(json_file_path)



default_app = firebase_admin.initialize_app(cred_obj, {
	'databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'
	})


# Ottieni un riferimento al percorso del database dove desideri salvare i dati
ref = db.reference("/")

app = Flask(__name__)

# API Route

@app.route("/setUserID/<string:sessionID>/<string:userID>", methods=['POST'])
def setUserID(sessionID, userID):
    print(sessionID, userID)

    # Crea un nuovo nodo nel database con sessionID come chiave 
    ref.child(sessionID).set({
        'userID': userID
    })

    print(userID + 'for' + sessionID)

    return 'UserID saved successfully.'

@app.route("/setSchoolID/<string:sessionID>/<string:schoolID>", methods=['POST'])
def setSchoolID(sessionID, schoolID):
    print(sessionID, schoolID)

    # Crea un nuovo nodo nel database con sessionID come chiave 
    ref.child(sessionID).set({
        'schoolID': schoolID
    })

    return 'School saved successfully.'

@app.route("/setStartEndDate/<string:sessionID>/<string:startDate>/<string:endDate>", methods=['POST'])
def setStartEndDate(sessionID, startDate, endDate):
    print(sessionID, startDate, endDate)
    # Converti la data in formato stringa in un oggetto datetime
    startDateObj = datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S.%f")
    endtDateObj = datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S.%f")

    # Crea un nuovo nodo nel database con sessionID come chiave e la start_date come valore
    ref.child(sessionID).set({
        'startDate': startDateObj.isoformat(),  # Salva la data in formato ISO8601
        'endDate': endtDateObj.isoformat()
    })

    #print(userID+' updates start end date for: '+ sessionID)
    print(startDateObj, type(startDateObj))
    print(endtDateObj, type(endtDateObj))

    return 'Start date saved successfully.'

def runWeightBuilder():
    os.system("python WeightBuilder.py")

#def runOptimizationAlgorithm():
#    os.system("python Optimization_Manager.py")

@app.route("/startOptimization/<string:sessionID>")
def startOptimization(sessionID):
    #get per UserId
    ProblemData = ref.child(sessionID).get()
    print(ProblemData['endDate'])

    #get per tutti gli esami
    #ProblemData['ProgrammeStudy']

    #Call weightBuilder
    # thread= Thread(target= runWeightBuilder)
    # thread.start()

    #thread.join()

    #thread2 = Thread(target= runOptimizationAlgorithm)
    #thread2.start()

    #Start optimizer.py con i suoi input
    return 'Start process'

@app.route("/getSessionList")
def getSessionList():
    # get per sessionID
    session_list = list(ref.get().keys())

    response = json.dumps(session_list)  # Converti la lista in una stringa JSON
    return response

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
    ref.child(sessionID).set({
        'startDate': distCallsObj,
        'endDate': distExamsObj
    })

    print('Sto salvando dati per: ' + sessionID)
    print(distCallsObj, type(distCallsObj))
    print(distExamsObj, type(distExamsObj))

    return 'Settings saved successfully.'

@app.route("/setUnavailability/<string:sessionID>/<string:unavailID>/<string:type>/<string:name>/<path:dates>", methods=['POST'])
def setUnavailibility(sessionID, unavailID, type, name, dates):
    print(sessionID, name, dates)

    # Converti la stringa di date separata da "/" in una lista di stringhe
    date_list = dates.split("/")

    # Converti la lista di stringhe in una lista di oggetti datetime
    date_obj_list = [datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f").isoformat() for date_str in date_list]

    # Crea un nuovo nodo nel database con l'sessionID come chiave e la lista di date come valore
    ref.child(sessionID).child('unavailList').child(unavailID).set({
        'name': name,
        'type': type,
        'dates': date_obj_list
    }
    )

    print('Sto salvando dati per: ' + sessionID)
    #print(date_obj_list, type(date_obj_list))

    return 'Unavailability saved successfully.'


@app.route("/delete_unavail/<string:sessionID>/<string:unavailID>", methods=['POST'])
def deleteUnavailability(sessionID, unavailID):
    try:
        
        # Elimina l'intero blocco "unavailID" dal database
        doc_ref = db.reference(sessionID).child(unavailID)
        doc_ref.delete()
        
        return jsonify({'success': True, 'message': 'Blocco "unavailID" eliminato correttamente.'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

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

if __name__== "__main__":
    app.run(debug=True)
    
