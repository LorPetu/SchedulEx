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

def runOptimizationManager(flag_queue):
    print('The flow is started')
    flag_queue.put('Database exam getting will start in a few istants')
    runGetDatabaseExamData(flag_queue)
    flag_queue.put('Weight building will start in a few istants')
    runWeightBuilder(flag_queue)
    return