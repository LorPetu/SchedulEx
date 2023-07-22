from mip import Model, xsum, BINARY
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from utils import *

GUROBI_HOME = 'C:/gurobi1001/'


def solveScheduling(exams, problem_session):
    global status_list

    ## Define the days that are available from start to end date
    sessionID = problem_session.id
    availDates = []
    current_date=problem_session.startDate
    print(current_date)
    print(problem_session.startDate)
    while current_date <= problem_session.endDate:
        availDates.append(current_date)
        current_date += timedelta(days=1)

    num_appelli = int(problem_session.settings['numCalls']) #input("NUMERO APPELLI: ")
    distanza_1= int(problem_session.settings['minDistanceExams'])


    # Creazione del problema di programmazione lineare
    prob = Model("EsameScheduler", sense='maximize', solver_name='GUROBI')

    # Optimization problme variables initialization
    s = {}  # Slot per assegnare agli esami
    x = {}  # Slot per assegnare due esami diversi

    for i, exam_i in enumerate(exams): 
        for k, date_k in enumerate(availDates): 
            # VARIABLE s_i_k: indicates if the exam i has a date assigned in the day k. BINARY    

            s[(i, k)] = prob.add_var(var_type=BINARY, name='s_%i_%i' % (i, k))

            # Now i'm interested in all the possible couple of exam and their assigned dates
            for j, exam_j in enumerate(exams):
                #if j != i:
                    for t, date_t in enumerate(availDates):
                        if k < t:
                            # VARIABLE x_i_k_j_t: indicates if the exam i is assigned in day k AND exam j in day t. BINARY

                            x[(i, k, j, t)] = prob.add_var(var_type=BINARY, name='x_%i_%i_%i_%i' % (i, k, j, t))
    # Update the Status
    status_list.setProgress(sessionID,"Variables created")

    # Creazione della funzione obiettivo
    objective = []
    for i, exam_i in enumerate(exams):
        for j, exam_j in enumerate(exams):
            if j!=i:
                for t, date_t in enumerate(availDates):
                    for k, date_k in enumerate(availDates):
                        if k < t:
                            objective.append((exam_i.effortWeight*exam_j.effortWeight)*exam_i.timeWeight[j] * (t - k) * x[(i, k, j, t)])

    prob.objective += xsum(objective)

    status_list.setProgress(sessionID,"Objective function created")

    # LOGIC Constraints: in this way we define the logical port AND for the x variables, and connect with the relative s variables
    for i, exam_i in enumerate(exams):
        for j, exam_j in enumerate(exams):
            #if j!=i:
                for k, date_k in enumerate(availDates):
                    for t, date_t in enumerate(availDates):
                        if t > k:
                            prob += s[(i, k)] + s[(j, t)] - 2*x[(i, k, j, t)] <=1
                            prob += s[(i, k)] + s[(j, t)] - 2*x[(i, k, j, t)] >=0
                        if t == k and j!=i:
                            prob += s[(i, k)] + s[(j, t)] <=1 #per ogni giorno io non voglio avere gli esami lo stesso giorno, o uno o l'altro
    
    # Here we set that for each exam we want to have just num_appelli of date assignation
    for i, exam_i in enumerate(exams):
        print(s[(i, k)])
        prob += xsum(s[(i, k)] for k, date_k in enumerate(availDates)) == num_appelli

    status_list.setProgress(sessionID,"Logic constraints set")

    ## Time constraint

    for i, exam_i in enumerate(exams):
        for j, exam_j in enumerate(exams):
            if j!=i:
                for k, date_k in enumerate(availDates):  
                    for t, date_t in enumerate(availDates):                                
                        if t > k: 
                            # Check if exams are in the same semester
                            if exam_i.sem == exam_j.sem:
                                if t-k!=distanza_1:
                                    # Set the distance greater than the minimum required for all the combinations of dates with these exams 
                                    # eq1 x_i_k_j_t*(t-k)>=x_i_k_j_t*(distanza_1)
                                    prob += x[(i, k, j, t)]*(t-k-distanza_1)>=0 
                                else:
                                    #if t-k=distanza_1 the eq1 is always equal to zero, so we need to set this variable to zero
                                    prob += x[(i, k, j, t)]==0

    if num_appelli>1:
        for i, exam_i in enumerate(exams):
                for k, date_k in enumerate(availDates):
                    for t, date_t in enumerate(availDates):                    
                            if t > k:
                                if t-k!=exam_i.minDistanceCalls: #distanza_2: # 
                                    # Set the distance greater than the minimum required for all the combinations of dates with these exams 
                                    # eq1 x_i_k_j_t*(t-k)>=x_i_k_j_t*(distanza_1)
                                    prob += x[(i, k, i, t)]*(t-k-exam_i.minDistanceCalls)>=0 #distanza2 -> exam_iminDistanceCalls
                                else:
                                    #if t-k=distanza_1 the eq1 is always equal to zero, so we need to set this variable to zero
                                    prob += x[(i, k, i, t)]==0

    status_list.setProgress(sessionID,"Time constraints set")

    ## Unavailability constraints

    for k, date_k in enumerate(availDates):
        

        #per ogni data indisponibilità poli e domeniche (Sunday 0) faccio la sommatoria per tutti gli esami
        if date_k.weekday()==0: 
            prob += xsum(s[(i, k)] for i, exam_i in enumerate(exams)) == 0
            
        #per ogni esame, controllo se la data corrente appartiene all'array delle indisponibilità del prof
        for i, exam_i in enumerate(exams):
            if date_k in exam_i.unavailDates:
               prob += s[(i, k)] == 0
            if exam_i.assignedDates!=[]:
                print(type(date_k),type(exam_i.assignedDates[0]))
            print('optimizer: exam inf',exam_i.course_name,)
            if date_k in exam_i.assignedDates:
                print('optimizer: if date_k in assignedDates',exam_i.course_name)
                prob += s[(i, k)] == 1



    status_list.setProgress(sessionID,"Unavailability constraints set")

    # Be careful, the output will be huge
    #print(prob)
    prob.write("ExamScheduler.lp")
    status_list.setProgress(sessionID,'The problem has successfully formulated')
    # Last updated objective and time
    # prob._cur_obj = float('inf')
    # prob._time = time.time()
    # Risoluzione del problema di programmazione lineare intera
    status_list.setProgress(sessionID,'Start optimization')
    prob.optimize()
    prob.store_search_progress_log
    print(prob.status.value)

    #for i in range(len(prob.vars)):
    #    print(f"{prob.vars[i].name} = {prob.vars[i].x}")
    # Stampa dei risultati
    M=np.zeros([len(exams),len(availDates)])
    print("## MATRIX CALENDAR ##")
    for i, exam_i in enumerate(exams):
        for k, date_k in enumerate(availDates):
            if date_k in exam_i.unavailDates:
                M[i][k]= '#' if s[(i, k)].x==1 else 0               
            if(date_k.weekday()!=6):
                M[i][k]= 1 if s[(i, k)].x==1 else 0
            else:
                M[i][k]= 7
                
    print(M)
    print("\n\n\n\n")

    for i, exam_i in enumerate(exams):
        exam_i.assignedDates=[]
        for k, date_k in enumerate(availDates):
                if M[i][k]==1:
                    exam_i.assignedDates.append(date_k) 
    # for exam_i in exams:
    #     assigned_dates_formatted = [date.strftime("%Y-%m-%d") for date in exam_i.assignedDates]
    #     exam_i.assignedDates = assigned_dates_formatted
    #     print(exam_i.assignedDates)         
          
    return [prob.status.value, exams]