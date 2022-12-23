#########################################
#       Mariadb database connector      #
#########################################

import mariadb
from __init__ import *


def db(surname):
    ## makes an variable with connection information of the database.
    connection = mariadb.connect(user="fys_test_user", password='jFmUNELH[Aigaqw[', host="127.0.0.1", database="fys_test")

    print(connection) ## Pint the status of the connection
    mycursor = connection.cursor()
    mycursor.execute("USE fys_test;")
    mycursor.execute(f"SELECT ticketnummer FROM vlucht WHERE achternaam = '{surname}';")
    result = mycursor.fetchone()
    data = result[0]
    print(data)

    connection.close
    return data