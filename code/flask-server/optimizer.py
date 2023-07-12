from mip import Model, xsum, BINARY
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from utils import optStatus, verify

GUROBI_HOME = 'C:/gurobi1001/'

def solveScheduling(exams: list, startDate, endDate, status: optStatus):

    D = 15 # 25  # Numero di giorni disponibili # 51 giorni per la sessione estiva
    ## Define the days that are available from start to end date
    availDays = []
    current_date=startDate
    while current_date <= endDate:
        availDays.append(current_date)
        current_date += timedelta(days=1)

    ## Define current semester in which session is scheduling
    curr = 1  # Semestre corrente

    ## Create time weight respect all couples of exams
    w = [[int(2**(-0.3*abs(exams[i].exam.sem - exams[j].exam.sem))*1000)/100 + 10 * verify(exams[i].exam.sem==curr)*verify(exams[j].exam.sem==curr) for j in len(exams) ] for i in len(exams)]  # Pesi  
    print(w)
    print("parameters set ok")
    num_appelli = 2#input("NUMERO APPELLI: ")
    distanza_1= int(input("distanza esami: "))
    distanza_2 = int(input("distanza appelli: "))

    print("input parameters set ok")

    # Creazione del problema di programmazione lineare
    prob = Model("EsameScheduler", sense='maximize', solver_name='GUROBI')
    # Creazione delle variabili
    s = {}  # Slot per assegnare agli esami
    x = {}  # Slot per assegnare due esami diversi
    for i in len(exams): #for all exams
        for k in len(availDays): #for all days
            # VARIABLE s_i_k: indicates if the exam i has a date assigned in the day k. BINARY    

            s[(i, k)] = prob.add_var(var_type=BINARY, name='s_%i_%i' % (i, k))

            # Now i'm interested in all the possible couple of exam and their assigned dates
            for j in len(exams):
                #if j != i:
                    for t in len(availDays):
                        if k < t:
                            # VARIABLE x_i_k_j_t: indicates if the exam i is assigned in day k AND exam j in day t. BINARY

                            x[(i, k, j, t)] = prob.add_var(var_type=BINARY, name='x_%i_%i_%i_%i' % (i, k, j, t))
    # Update the Status
    status.setStatus("Variables created")

    # Creazione della funzione obiettivo
    objective = []
    for i in len(exams):
        for j in len(exams):
            if j!=i:
                for t in len(availDays):
                    for k in len(availDays):
                        if k < t:
                            objective.append(w[i][j] * (t - k) * x[(i, k, j, t)])

    prob.objective += xsum(objective)

    status.setStatus("Objective function created")

    # LOGIC Constraints: in this way we define the logical port AND for the x variables, and connect with the relative s variables
    for i in len(exams):
        for j in len(exams):
            #if j!=i:
                for k in len(availDays):
                    for t in len(availDays):
                        if t > k:
                            prob += s[(i, k)] + s[(j, t)] - 2*x[(i, k, j, t)] <=1
                            prob += s[(i, k)] + s[(j, t)] - 2*x[(i, k, j, t)] >=0
                        if t == k and j!=i:
                            prob += s[(i, k)] + s[(j, t)] <=1 #per ogni giorno io non voglio avere gli esami lo stesso giorno, o uno o l'altro
    
    # Here we set that for each exam we want to have just num_appelli of date assignation
    for i in len(exams):
        print(s[(i, k)])
        prob += xsum(s[(i, k)] for k in len(availDays)) == num_appelli

    status.setStatus("Logic constraints set")

    ## Time constraint

    for i in len(exams):
        for j in len(exams):
            if j!=i:
                for k in len(availDays):  
                    for t in len(availDays):                                
                        if t > k: 
                            # Check if exams are in the same semester
                            if exams[i].exam.sem == exams[j].exam.sem:
                                if t-k!=distanza_1:
                                    # Set the distance greater than the minimum required for all the combinations of dates with these exams 
                                    # eq1 x_i_k_j_t*(t-k)>=x_i_k_j_t*(distanza_1)
                                    prob += x[(i, k, j, t)]*(t-k-distanza_1)>=0 
                                else:
                                    #if t-k=distanza_1 the eq1 is always equal to zero, so we need to set this variable to zero
                                    prob += x[(i, k, j, t)]==0


    if num_appelli>1:
        for i in len(exams):
                for k in len(availDays):
                    for t in len(availDays):                    
                            if t > k:
                                if t-k!=distanza_2:
                                    # Set the distance greater than the minimum required for all the combinations of dates with these exams 
                                    # eq1 x_i_k_j_t*(t-k)>=x_i_k_j_t*(distanza_1)
                                    prob += x[(i, k, i, t)]*(t-k-distanza_2)>=0
                                else:
                                    #if t-k=distanza_1 the eq1 is always equal to zero, so we need to set this variable to zero
                                    prob += x[(i, k, i, t)]==0

    status.setStatus("Time constraints set")

    ## Unavailability constraints

    count =0
    for k in len(availDays):
        count += 1
        #print(count)
        if count == 7: #per ogni data indisponibilità poli e domeniche faccio la sommatoria per tutti gli esami
            #print(s[(i, k)].x)
            prob += xsum(s[(i, k)] for i in len(exams)) == 0
            count=0
        #per ogni esame, controllo se la data corrente appartiene all'array delle indisponibilità del prof

    status.setStatus("indisponibilità constraints set")



    # Be careful, the output will be huge
    #print(prob)
    prob.write("ExamScheduler.lp")
    print('🤔 The problem has successfully formulated')
    # Last updated objective and time
    # prob._cur_obj = float('inf')
    # prob._time = time.time()
    # Risoluzione del problema di programmazione lineare intera
    prob.optimize() #callback=cb)
    prob.store_search_progress_log
    print(prob.status.value)

    #for i in range(len(prob.vars)):
    #    print(f"{prob.vars[i].name} = {prob.vars[i].x}")
    # Stampa dei risultati

    M=np.zeros([N,S])
    print("## MATRIX CALENDAR ##")
    for i in len(exams):
        count=0
        for k in len(availDays):
            count += 1
            #M[i][k]= 1 if s[(i, k)].x==1 else 0
            if(count!=7):
                M[i][k]= 1 if s[(i, k)].x==1 else 0
            else:
                M[i][k]= 7
                count=0
    print(M)
        
    # Definisci la data di inizio e fine
    data_inizio = datetime.date(2023, 1, 1)

    # Crea un elenco di date corrispondenti come header delle colonne
    date_colonne = [data_inizio + datetime.timedelta(days=S) for i in len(availDays)]


    DF = pd.DataFrame(M, columns=date_colonne)
    DF.to_csv("calendar.csv") 