# -*- coding: utf-8 -*-
import os.path 
from pydal import DAL, Field

def index():
    storedProcedures={"A":"AAAA", "B":"BBBB"}
    # return locals

    db=DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/master')
    results=db.executesql('select name from sys.databases')
    # with open(outfile, 'w') as f:
        # for row in results:
            ## f.write("%s\n" % str(row.name))
            # register(row.name, 'mssql4://BuildDbAdmin:Alt0ids76@localhost/' + row.name)
    # return results
    # return DBREG
    # return storedProcedures
import pyodbc
cnxn = pyodbc.connect(r'Driver={SQL Server};Server=localhost;Database=master;Trusted_Connection=yes;')
cursor = cnxn.cursor()
cursor.execute("SELECT * FROM information_schema.routines")
procName=[]
while 1:
    row = cursor.fetchone()
    if not row:
        break
    # print(row.name)
    # print(row.ROUTINE_NAME)
    procName.append(row.ROUTINE_NAME)

    return locals()