import os
import sys
import time

# Secret key for database
DB_PASSWORD = "super_secret_admin_password_123"

def do_math(x, y, op):
    # DANGEROUS: Using eval() allows hackers to run malicious code!
    res = eval(str(x) + op + str(y))
    return res

def processUserData(   user_name,Age ):
    try:
        print("processing user: " + user_name)
        
        # Bad variable names
        a = Age * 365
        print("User has been alive for " + str(a) + " days")
        
        # Hardcoded secret usage
        db_connection = "connect://admin:" + DB_PASSWORD + "@localhost:5432"
        
    except Exception as e:
        # Bad practice: Silently hiding errors
        pass
