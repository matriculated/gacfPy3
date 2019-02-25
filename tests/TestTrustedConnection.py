import pyodbc
# conn = pyodbc.connect("Driver={"SQL Driver"};Server= "ServerName";Database="DatabaseName";Trusted_Connection=yes")
# conn0 = pyodbc.connect(r'Driver={SQL Driver};Server=SQL2017;Database=AppAuth;Trusted_Connection=yes;')

#import pyodbc
# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=.\SQLEXPRESS;Database=myDB;Trusted_Connection=yes;')
# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=SQL2017;Database=AppAuth;Trusted_Connection=yes;')
# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=SQL2017;Database=ApplicationConfiguration;Trusted_Connection=yes;')

#cnxn = pyodbc.connect(r'Driver={SQL Server};Server=localhost;Database=ApplicationConfiguration;Trusted_Connection=yes;')
#cursor = cnxn.cursor()
#cursor.execute("SELECT * FROM tbcPropertyConfig")
#while 1:
#    row = cursor.fetchone()
#    if not row:
#        break
#    print(row.PropertyName)
## cnxn.close()
#print("==================")



cnxn = pyodbc.connect(r'Driver={SQL Server};Server=localhost;Database=master;Trusted_Connection=yes;')
cursor = cnxn.cursor()
cursor.execute("select name from sys.databases")

while 1:
    row = cursor.fetchone()
    if not row:
        break
    print(row.name)


print("==================")
# cursor.execute("SELECT TABLE_SCHEMA FROM information_schema.tables group by tables.TABLE_SCHEMA")
# cursor.execute("use ApplicationConfiguration; SELECT * FROM information_schema.routines")
cursor.execute("SELECT * FROM information_schema.routines")

while 1:
    row = cursor.fetchone()
    if not row:
        break
    # print(row.name)
    print(row.ROUTINE_NAME)


# SELECT TABLE_SCHEMA FROM information_schema.tables group by tables.TABLE_SCHEMA
# use master; SELECT * FROM information_schema.SCHEMATA
# use master; SELECT * FROM information_schema.tables 
# use ApplicationConfiguration; SELECT * FROM information_schema.tables 
# use ApplicationConfiguration; SELECT * FROM information_schema.routines






cnxn.close()
