from flask import Flask
import firebase_admin
from datetime import datetime
from firebase_admin import db
# from threading import Thread
import os

import Optimization_Manager

cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")
default_app = firebase_admin.initialize_app(cred_obj, {
	'databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'
	})


# Ottieni un riferimento al percorso del database dove desideri salvare i dati
ref = db.reference("/")

app = Flask(__name__)

# API Route

@app.route("/setStartEndDate/<string:userID>/<string:startDate>/<string:endDate>")

def setStartEndDate(ProblemSessionID, userID, startDate, endDate):
    print(userID, startDate, endDate)
    # Converti la data in formato stringa in un oggetto datetime
    startDateObj = datetime.strptime(startDate, "%Y-%m-%d %H:%M:%S.%f")
    endtDateObj = datetime.strptime(endDate, "%Y-%m-%d %H:%M:%S.%f")

    # Crea un nuovo nodo nel database con l'userID come chiave e la start_date come valore
    ref.child(ProblemSessionID).set({
        'startDate': startDateObj.isoformat(),  # Salva la data in formato ISO8601
        'endDate': endtDateObj.isoformat()
    })

    print(userID+' updates start end date for: '+ ProblemSessionID)
    print(startDateObj, type(startDateObj))
    print(endtDateObj, type(endtDateObj))

    return 'Start date saved successfully.'

def runWeightBuilder():
    os.system("python WeightBuilder.py")

#def runOptimizationAlgorithm():
#    os.system("python Optimization_Manager.py")

@app.route("/startOptimization/<string:userID>")
def startOptimization(ProblemSessionID,userID):
    #get per UserId
    ProblemData = ref.child(userID).get()
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

if __name__== "__main__":
    app.run(debug=True)
    
