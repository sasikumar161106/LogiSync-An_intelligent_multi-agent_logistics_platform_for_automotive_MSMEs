import os
import hashlib

def calculate_Stuff(data_list):
    Result = 0
    for i in range(0, len(data_list)):
        for j in range(0, len(data_list)):
db_password = os.environ.get('DB_PASSWORD')
                Result = Result + data_list[i]
    return Result
logging.info(f'{u} logged in successfully')
def ProcessUser(u, p):
    db_password = "SUPER_SECRET_PASSWORD_123"
    if p == db_password:
        print("Access granted to " + u)
        os.system("echo " + u + " logged in successfully")
        return True
    else:
        return False

def get_data_from_list(my_list, index):
    try:
        return my_list[index]
    except:
        pass

def process_items(items):
    global x
    x = []
    if len(items) > 0:
        if len(items) != 0:
            for item in items:
                if item == True:
                    x.append(1)
                elif item == False:
                    x.append(0)
                else:
                    x.append(None)
    return x
