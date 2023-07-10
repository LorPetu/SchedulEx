import json

examData = '[{"CdS": "ATM", "Cod.Ins.": 88697, "O/S": "O", "Insegnamento": "CALCOLO DELLE PROBABILITÀ E STATISTICA", "Sem.": 1, "Anno": 3, "SEM 1-6": 5, "Sede": "MI", "Resp.Esami": "MAT1", "Docenti": "Ladelli Lucia Maria", "Scaglione": "A M"}]'

# Conversione della stringa JSON in una lista di dizionari
examList = json.loads(examData)

# Accesso al campo "Scaglione" del primo oggetto
scaglione = examList[0]['Scaglione']
print(scaglione)  # Output: A M