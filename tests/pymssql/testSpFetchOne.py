from os import getenv
import sys
import pymssql

sys.path.append('C:\\Program Files\\Git\\usr\\local\\reso')
from pyObjInternal import gcm
from pyObjInternal import goatt

#server = getenv("PYMSSQL_TEST_SERVER")
#user = getenv("PYMSSQL_TEST_USERNAME")
#password = getenv("PYMSSQL_TEST_PASSWORD")
server = "localhost"
user = "BuildDbAdmin"
password = "Alt0ids76"

conn = pymssql.connect(server, user, password, "tempdb")
cursor = conn.cursor()

#select * 
#  from DatabaseName.information_schema.routines 
# where routine_type = 'PROCEDURE'

##print(cursor.execute(" select * from master.information_schema.routines where routine_type = 'PROCEDURE' and Left(Routine_Name, 3) NOT IN ('sp_', 'xp_', 'ms_')"))
##print(cursor.execute(" select * from master.information_schema.routines "))
#cursor.execute("select count(*) from information_schema.routines ")
#print(cursor.fetchone)
##cursor.nextset()
#cursor.close()

#cursor = conn.cursor()
cursor.execute("select * from information_schema.routines ")
#print len(cursor.fetchall())
#print(cursor.rowcount)

print(gcm(cursor))
print(goatt(cursor))

result = list(cursor.fetchone())
print(result)
result = list(cursor.fetchone())
print(result)
cursor.close()

cursor1 = conn.cursor()
args= ('Mike')
cursor1.callproc("getPersonLike", (args,))
# cursor.callproc("getPersonLike", (("Mike"),))
cursor1.nextset()
result = list(cursor1.fetchone())
cursor1.close()
conn.commit()
print(result)