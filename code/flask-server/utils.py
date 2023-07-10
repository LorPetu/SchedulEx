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
           
# {
#     userID: '',
#     problemData: {
#         StartDate:,
#         EndDate:,
#         UnavailList: List<Unavail> [],
#         ProgrammeStudy: ''
#     }
# }
