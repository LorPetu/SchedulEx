import sys
import ast
import json
from utils import *
from flask import Flask, jsonify
import firebase_admin
from datetime import datetime
from firebase_admin import db
# from threading import Thread
import os
import pandas as pd
import subprocess # per far partire Optimization_Manager

def getSessionData(sessionID):

    cred_obj = firebase_admin.credentials.Certificate("./schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json")

    #json_file_path = "C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\schedulex-723a8-firebase-adminsdk-mau2x-c93019364b.json"
    #cred_obj = firebase_admin.credentials.Certificate(json_file_path)

    default_app = firebase_admin.initialize_app(cred_obj, {
        'databaseURL':'https://schedulex-723a8-default-rtdb.firebaseio.com/'
        })

    # Ottieni un riferimento al percorso del database dove desideri salvare i dati
    ref = db.reference("/")
    #get per sessionID
    SessionData = ref.child(sessionID).get()
    print(SessionData)

    return SessionData

def getWeights(examData):
    # Componi il comando per invocare lo script Optimization_Manager con sessionID come argomento
    comando = ["python", "WeightBuilder.py", examData]

    # Esegui il comando utilizzando subprocess
    examWeights=subprocess.run(comando)


    return examWeights

def getDatabaseExamData():
    # Componi il comando per invocare lo script Optimization_Manager con sessionID come argomento
    comando = ["python", "C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\getDEdata.py"]
    # Esegui il comando utilizzando subprocess
    ExamData=subprocess.check_output(comando, universal_newlines=True)
    
    # Conversione della stringa in una struttura dati Python
    examList = ast.literal_eval(ExamData)

    # Accesso al campo "Insegnamento" del primo oggetto
    insegnamento = examList[0]['Insegnamento']
    print(insegnamento)  # Output: Matematica

    return ExamData

def main(sessionID):
    #sessionData=getSessionData(sessionID)
    examData=getDatabaseExamData()
    #examWeights=getWeights(examData)

    # Operazioni da eseguire utilizzando il valore sessionID
    # ...
    return []

if __name__ == "__main__":
    # Verifica se sono stati passati almeno due argomenti
    #if len(sys.argv) < 2:
    #    print("Usage: python Optimization_Manager.py <sessionID>")
     #   sys.exit(1)

    # Ottieni il valore sessionID dall'argomento della riga di comando
    #sessionID = sys.argv[1]

    # Chiamata alla funzione main() passando il valore sessionID
    sessionID=0
    main(sessionID)
