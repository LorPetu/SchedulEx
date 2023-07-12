class Unavail:
    def __init__(self, id, type, dates, name):
        self.id = id
        self.type = type
        self.dates = dates
        self.name=name
        
class ProblemSession:
    def __init__(self,id,school,status,description,user):
        self.id =id
        self.school=school
        self.status=status
        self.description=description
        self.user=user
           

class optStatus:
    def __init__(self, status, sessionID):
        self.__status = status
        self.sessionID = sessionID
    
    def getStatus(self)-> str:
        return self.__status

    def setStatus(self,new_status):
        self.__status=new_status

if __name__ == "__main__":
    status=optStatus("NOT STARTED")

    print(status.getStatus())
    status.setStatus('STARTED')

    print(status.getStatus())

def verify(condition):
    if condition== True:
        return 1
    else:
        return 0