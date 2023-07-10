import json
from flask import Flask, jsonify
import firebase_admin
from datetime import datetime
from firebase_admin import db
from threading import Thread
import os

# import Optimization_Manager

#cred_obj = firebase_admin.credentials.Certificate("/schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")

json_file_path = "C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json"
cred_obj = firebase_admin.credentials.Certificate(json_file_path)



default_app = firebase_admin.initialize_app(cred_obj, {
	'databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'
	})


# Ottieni un riferimento al percorso del database dove desideri salvare i dati
ref = db.reference("/")

app = Flask(__name__)

# API Route

@app.route("/setStartEndDate/<string:userID>/<string:startDate>/<string:endDate>")

def setStartEndDate(userID, startDate, endDate):
    print(userID, startDate, endDate)
    # Converti la data in formato stringa in un oggetto datetime
    startDateObj = datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S.%f")
    endtDateObj = datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S.%f")

    # Crea un nuovo nodo nel database con l'userID come chiave e la start_date come valore
    ref.child(userID).set({
        'startDate': startDateObj.isoformat(),  # Salva la data in formato ISO8601
        'endDate': endtDateObj.isoformat()
    })

    print('Sto salvando dati per: ' + userID)
    print(startDateObj, type(startDateObj))
    print(endtDateObj, type(endtDateObj))

    return 'Start date saved successfully.'

def runWeightBuilder():
    os.system("python WeightBuilder.py")

#def runOptimizationAlgorithm():
#    os.system("python Optimization_Manager.py")

@app.route("/startOptimization/<string:userID>")
def startOptimization(userID):
    #get per UserId
    ProblemData = ref.child(userID).get()
    print(ProblemData['endDate'])

    #get per tutti gli esami
    #ProblemData['ProgrammeStudy']

    #Call weightBuilder
    thread= Thread(target= runWeightBuilder)
    thread.start()

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

@app.route("/setSettings/<string:sessionID>/<string:distCalls>/<string:distExams>")
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

@app.route("/setUnavailability/<string:sessionID>/<string:name>/<path:date>")
def setSettings(sessionID, name, date):
    print(sessionID, name, date)

    # Converti la stringa di date separata da "/" in una lista di stringhe
    date_list = date.split("/")

    # Converti la lista di stringhe in una lista di oggetti datetime
    date_obj_list = [datetime.datetime.strptime(date_str, "%Y-%m-%d") for date_str in date_list]

    # Crea un nuovo nodo nel database con l'sessionID come chiave e la lista di date come valore
    ref.child(sessionID).set({
        name: date_obj_list,
    })

    print('Sto salvando dati per: ' + sessionID)
    print(date_obj_list, type(date_obj_list))

    return 'Unavailability saved successfully.'



if __name__== "__main__":
    app.run(debug=True)
