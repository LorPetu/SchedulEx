import sys

def main(examData):
    
    # Operazioni da eseguire utilizzando il valore examData
    # ...

    # Restituisci i risultati o esegui ulteriori operazioni
    # ...
    return []


if __name__ == "__main__":
    # Verifica se è stato passato almeno un argomento
    if len(sys.argv) < 2:
        print("Usage: python WeightBuilder.py <examData>")
        sys.exit(1)

    # Ottieni il valore examData dall'argomento della riga di comando
    examData = sys.argv[1]

    # Chiamata alla funzione main() passando il valore examData
    main(examData)
