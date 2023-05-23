from mip import Model, xsum, BINARY
import numpy as np
import pandas as pd
import datetime
# import gurobipy as gp
# from gurobipy import GRB
# import time

# def cb(model, where):
#     if where == GRB.Callback.MIPNODE:
#         # Get model objective
#         obj = model.cbGet(GRB.Callback.MIPNODE_OBJBST)

#         # Has objective changed?
#         if abs(obj - model._cur_obj) > 1e-8:
#             # If so, update incumbent and time
#             model._cur_obj = obj
#             model._time = time.time()

#     # Terminate if objective has not improved in 20s
#     if time.time() - model._time > 20:
#         model.terminate()

GUROBI_HOME = 'C:/gurobi1001/'

# Definizione dei parametri
D = 15 # 25  # Numero di giorni disponibili # 51 giorni per la sessione estiva
F = 3  # Numero di fasce orarie
S = D # Numero di slot disponibili
N = 6  # Numero di esami PER AUTOMAZIONE SONO 25
#z = [1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6]  # Semestre corrispondente ad ogni esame
#b = [1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]  # Indicatori se l'esame è nel semestre corrente
z = [1, 1, 2, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6]  # Semestre corrispondente ad ogni esame
b = [1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0]
#z = [1, 2, 3, 4, 5, 6]  # Semestre corrispondente ad ogni esame
#b = [1, 0, 1, 0, 1, 0]

curr = 1  # Semestre corrente
w = [[int(2**(-0.3*abs(z[i] - z[j]))*1000)/100 + 10 * b[i]*b[j] for j in range(N) ] for i in range(N)]  # Pesi  
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
for i in range(N):
    for k in range(S):
        s[(i, k)] = prob.add_var(var_type=BINARY, name='s_%i_%i' % (i, k))
        for j in range(N):
            #if j != i:
                for t in range(S):
                    if k < t:
                        x[(i, k, j, t)] = prob.add_var(var_type=BINARY, name='x_%i_%i_%i_%i' % (i, k, j, t))

print("Variables created")

# Creazione della funzione obiettivo
objective = []
for i in range(N):
    for j in range(N):
        if j!=i:
            for t in range(S):
                for k in range(S):
                    if k < t:
                        objective.append(w[i][j] * (t - k) * x[(i, k, j, t)])
prob.objective += xsum(objective)

print("Objective function created")

# LOGIC Constraints
for i in range(N):
    for j in range(N):
        #if j!=i:
            for k in range(S):
                for t in range(S):
                    if t > k:
                        prob += s[(i, k)] + s[(j, t)] - 2*x[(i, k, j, t)] <=1
                        prob += s[(i, k)] + s[(j, t)] - 2*x[(i, k, j, t)] >=0
                    if t == k and j!=i:
                        prob += s[(i, k)] + s[(j, t)] <=1 #per ogni giorno io non voglio avere gli esami lo stesso giorno, o uno o l'altro

for i in range(N):
    print(s[(i, k)])
    prob += xsum(s[(i, k)] for k in range(S)) == num_appelli

print("Logic constraints set")

## Time constraint

for i in range(N):
    for j in range(N):
        if j!=i:
            for k in range(S):  
                for t in range(S):                                
                    if t > k: 
                        if z[i] == z[j]:
                            if t-k!=distanza_1: 
                                prob += x[(i, k, j, t)]*(t-k-distanza_1)>=0 #affinchè gli esami dello stesso semestre siano ad almeno due notti di distanza
                            else:
                                prob += x[(i, k, j, t)]==0


if num_appelli>1:
    for i in range(N):
            for k in range(S):
                for t in range(S):                    
                        if t > k:
                            if t-k!=distanza_2:
                                prob += x[(i, k, i, t)]*(t-k-distanza_2)>=0
                            else:
                                prob += x[(i, k, i, t)]==0

print("Time constraints set")

## Indisponibilità constraints

count =0
for k in range(S):
  count += 1
  #print(count)
  if count == 7:
    #print(s[(i, k)].x)
    prob += xsum(s[(i, k)] for i in range(N)) == 0
    count=0

print("indisponibilità constraints set")

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
for i in range(N):
    count=0
    for k in range(S):
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
date_colonne = [data_inizio + datetime.timedelta(days=S) for i in range(S)]


DF = pd.DataFrame(M, columns=date_colonne)
DF.to_csv("calendar.csv") 