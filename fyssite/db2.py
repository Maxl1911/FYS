#########################################
#       Mariadb database connector      #
#########################################

import mariadb
from __init__ import *


def db(surname):
    ## makes an variable with connection information of the database.
    connection = mariadb.connect(user="corendon", password='corendon', host="127.0.0.1", database="Corendon")

    print(connection) ## Pint the status of the connection
    mycursor = connection.cursor()
    # mycursor.execute("USE Corendon;")
    # mycursor.execute("SELECT ticketnummer FROM Passagier WHERE achternaam = %s'", (surname, ))
    mycursor.execute("SELECT ticketnummer FROM Passagier WHERE achternaam = '%s'", (surname, ));
    mycursor.execute("SELECT ticketnummer FROM Passagier WHERE achternaam = %(surname)s", {'surname':>

    result = mycursor.fetchone()
    data = str(result[0])
    print(data)

    connection.close
    return data
