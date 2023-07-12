import time

def runGetDatabaseExamData(flag_queue):
    flag_queue.put('Database exam getting in progess')
    i = 2
    while i > 1:
        print('Database exam getting is running')
        time.sleep(2)
    flag_queue.put('Database exam getting has finished')

def runWeightBuilder(flag_queue):
    flag_queue.put('Weight building in progess')
    i = 2
    while i > 1:
        print('Weight building is running')
        time.sleep(3)
    flag_queue.put('Weight building in progess')

def runOptimizationManager(flag_queue, sessionID): 

    ## Ottieni in base a sessionID i valori del database Problem 
    ##

    ## Itera ogni CdS della scuola 
        ## List<optExam> resultsExams = [] DEVE ESSERE UN SET

        ## Ottieni esami del CdS list semplice
            #-> get al database exam per CdS 
            #-> per ognuno crea optExam(exam: exam, altri campi inizializzati vuoti)
            #-> List<optExam> unprocessedExams = list.map(value=optExam(exam:value, ))

        ## iter ogni exam di unprocessedExams 
            ## if (exam in resultsExams) verifica codice insegnamento
                #-> aggiorno l'elemento exam con resultExams[index] (elemnto trovato)
            ## else
                ## build unavailDates and update on exam
                    #-> 
                ## build effortWeight
                    #-> call weightBuilder
        
        ## resultExams.add(startOptimization(unprocessedList)) aggiungo al set gli elementi unici non schedulati precedentemente

    ## Alla fine di tutti i CdS converto il risultato finale resultExams in json
        ## aggiungo il json al Database problem in 'results': per il relativo sessionID


    # print('The flow is started')
    # flag_queue.put('Database exam getting will start in a few istants')
    # runGetDatabaseExamData(flag_queue)
    # flag_queue.put('Weight building will start in a few istants')
    # runWeightBuilder(flag_queue)
    return