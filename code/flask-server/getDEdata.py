import pandas as pd
import json
df = pd.read_excel("C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\Database esami.xlsx")
def countColumns():
    # Carica il file Excel utilizzando pandas
    
    #df.columns
    numero_celle = 0

    # Itera sulle celle della prima riga
    for cell in df.iloc[0]:
        # Controlla se la cella è vuota
        if pd.isnull(cell):
            break
        numero_celle += 1

    return numero_celle

def getNumeroEsami():
    # Carica il file Excel utilizzando pandas
    df = pd.read_excel("C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\Database esami.xlsx")

    numero_celle_non_vuote = 0

    # Seleziona il foglio di lavoro desiderato dal DataFrame
    sheet = df.iloc[:, 0]  # Seleziona la prima colonna

    # Itera sulle celle della colonna
    for cell in sheet:
        # Controlla se la cella non è vuota
        if pd.notnull(cell):
            numero_celle_non_vuote += 1

    numeroEsami = numero_celle_non_vuote - 1

    return numeroEsami

def createObjects():
    # Carica il file Excel utilizzando pandas
    df = pd.read_excel("C:\\Users\\Utente\\Desktop\\SchedulEx\\code\\flask-server\\Database esami.xlsx")

    # Calcola il numero di righe da considerare
    numeroEsami = getNumeroEsami()
    numeroVoci = countColumns()

    # Lista per salvare gli oggetti
    oggetti = []

    # Ottieni la prima riga come lista di nomi dei campi
    nomi_campi = df.columns.tolist()[:numeroVoci]

    # Itera sulle righe del DataFrame
    for index, row in df.iterrows():
        # Seleziona solo le prime 11 colonne della riga
        riga_dati = row[:numeroVoci].tolist()
        
        # Crea un oggetto con i valori della riga
        oggetto = {}
        for i, campo in enumerate(nomi_campi):
            oggetto[campo] = riga_dati[i]
        
        # Aggiungi l'oggetto alla lista
        oggetti.append(oggetto)

        # Esci dal ciclo se hai raggiunto il numero desiderato di righe
        if index == numeroEsami:
            break
    

    return oggetti


def main():
    # Chiamata alla funzione createObjects()
    # oggetti = createObjects()
    # Converti la lista in formato JSON
    #json_data = json.dumps(oggetti)


    # Stampa gli oggetti
    #for oggetto in oggetti:
    #print(oggetti)
    print(df)
    print(type(df))

if __name__ == "__main__":
    main()

