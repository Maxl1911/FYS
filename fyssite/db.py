import mariadb
connection = mariadb.connect(user="fys_test_user", password='jFmUNELH[Aigaqw[', host="127.0.0.1", database="fys_test")
connection.close

cursor = connection.cursor()
query = "SELECT achternaam, voornaam FROM vlucht WHERE achternaam = 'luiten'"
cur = connection.cursor()
cur.execute(query)

entries = cur.execute(query)
#for (ticketnummer, voornaam, achternaam, vluchtnummer) in cur:
    #print (f"{ticketnummer}, {voornaam}, {achternaam} ,{vluchtnummer}")
#for (achternaam, voornaam) in cur:
   # print(f"{achternaam}")

result = cur.fetchall()
print(result)

connection.close()