from mip import Model, xsum, BINARY
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from utils import *

GUROBI_HOME = 'C:/gurobi1001/'


def solveScheduling(exams, problem_session):

    ## Define the days that are available from start to end date
    availDates = []
    current_date=problem_session.start_date
    while current_date <= problem_session.end_date:
        availDates.append(current_date)
        current_date += timedelta(days=1)

    num_appelli = problem_session.callsNumber #input("NUMERO APPELLI: ")
    distanza_1= problem_session.settings[0]
    distanza_2 = problem_session.settings[1] # non stiamo considerando casi dove un esame ha la sua distanza specifica


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
    status.setStatus("Variables created")

    # Creazione della funzione obiettivo
    objective = []
    for i, exam_i in enumerate(exams):
        for j, exam_j in enumerate(exams):
            if j!=i:
                for t, date_t in enumerate(availDates):
                    for k, date_k in enumerate(availDates):
                        if k < t:
                            objective.append(w[i][j] * (t - k) * x[(i, k, j, t)])

    prob.objective += xsum(objective)

    status.setStatus("Objective function created")

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

    status.setStatus("Logic constraints set")

    ## Time constraint

    for i, exam_i in enumerate(exams):
        for j, exam_j in enumerate(exams):
            if j!=i:
                for k, date_k in enumerate(availDates):  
                    for t, date_t in enumerate(availDates):                                
                        if t > k: 
                            # Check if exams are in the same semester
                            if exam_i.exam.sem == exam_j.exam.sem:
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
                                if t-k!=distanza_2: # exam_i.minDistanceCalls
                                    # Set the distance greater than the minimum required for all the combinations of dates with these exams 
                                    # eq1 x_i_k_j_t*(t-k)>=x_i_k_j_t*(distanza_1)
                                    prob += x[(i, k, i, t)]*(t-k-distanza_2)>=0 #distanza2 -> exam_iminDistanceCalls
                                else:
                                    #if t-k=distanza_1 the eq1 is always equal to zero, so we need to set this variable to zero
                                    prob += x[(i, k, i, t)]==0

    status.setStatus("Time constraints set")

    ## Unavailability constraints

    for k, date_k in enumerate(availDates):

        #per ogni data indisponibilità poli e domeniche faccio la sommatoria per tutti gli esami
        if date_k.weekday()==6: 
            prob += xsum(s[(i, k)] for i, exam_i in enumerate(exams)) == 0
            
        #per ogni esame, controllo se la data corrente appartiene all'array delle indisponibilità del prof
        for i, exam_i in enumerate(exams):
            if date_k in exam_i.unavailDates:
               prob += s[(i, k)] == 0

    status.setStatus("Unavailability constraints set")

    # Be careful, the output will be huge
    #print(prob)
    prob.write("ExamScheduler.lp")
    status.setStatus('The problem has successfully formulated')
    # Last updated objective and time
    # prob._cur_obj = float('inf')
    # prob._time = time.time()
    # Risoluzione del problema di programmazione lineare intera
    status.setStatus('Start optimization')
    prob.optimize() #callback=mycallback)
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

    for i, exam_i in enumerate(unprocessedExams):
        exam_i.assigned_dates=[]
        for k, date_k in enumerate(availDates):
                if M[i][k]==1:
                    exam_i.assigned_dates.append(date_k) 
    for exam_i in unprocessedExams:
        assigned_dates_formatted = [date.strftime("%Y-%m-%d") for date in exam_i.assigned_dates]
        exam_i.assigned_dates = assigned_dates_formatted
        print(exam_i.assigned_dates)         
            
    return exams


if __name__=="__main__":
    unprocessedExams = create_random_optexams_list(5)
    unprocessedExams[1].exam
    results = solveScheduling(exams=unprocessedExams,startDate=datetime(2023,6,1),endDate=datetime(2023,6,16),status=current_status)
    for optexam in results:
        print(optexam.exam.sem, optexam.exam.professor, optexam.unavailDates, optexam.effortWeight, optexam.assignedDates)

