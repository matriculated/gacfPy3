import pyodbc
# conn = pyodbc.connect("Driver={"SQL Driver"};Server= "ServerName";Database="DatabaseName";Trusted_Connection=yes")
conn0 = pyodbc.connect('Driver={SQL Driver};Server=SQL2017;Database=AppAuth;Trusted_Connection=yes;')

import pyodbc
# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=.\SQLEXPRESS;Database=myDB;Trusted_Connection=yes;')
# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=SQL2017;Database=AppAuth;Trusted_Connection=yes;')
cnxn = pyodbc.connect(r'Driver={SQL Server};Server=SQL2017;Database=ApplicationConfiguration;Trusted_Connection=yes;')
cursor = cnxn.cursor()
cursor.execute("SELECT * FROM tbcPropertyConfig")
while 1:
    row = cursor.fetchone()
    if not row:
        break
    print(row.PropertyName)
cnxn.close()
