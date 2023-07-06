class Unavail:
    def __init__(self, id, type, dates, professor_or_classroom):
        self.id = id
        self.type = type
        self.dates = dates
        
        if type == 0:
            self.professor = professor_or_classroom
        elif type == 1:
            self.classroom = professor_or_classroom

# {
#     userID: '',
#     problemData: {
#         StartDate:,
#         EndDate:,
#         UnavailList: List<Unavail> [],
#         ProgrammeStudy: ''
#     }
# }
