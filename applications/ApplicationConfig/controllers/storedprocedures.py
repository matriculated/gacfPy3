# -*- coding: utf-8 -*-
import os.path 
from pydal import DAL, Field
import pyodbc

def index():
    # storedProcedures={"A":"AAAA", "B":"BBBB"}
    # return locals

    db=DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/master')
    results=db.executesql('select name from sys.databases')
    appdbs = []
    sysdbs = ['master', 'tempdb', 'model', 'msdb']
    for i in range(len(results)):
        results[i] = results[i].name.encode('ascii','ignore')
        if results[i] not in sysdbs:
            appdbs.append(results[i])
    # with open(outfile, 'w') as f:
        # for row in results:
            ## f.write("%s\n" % str(row.name))
            # register(row.name, 'mssql4://BuildDbAdmin:Alt0ids76@localhost/' + row.name)
    # return results
    # return DBREG
    # return storedProcedures
    # import pyodbc
    procName=[]
    for i in range(len(appdbs)):
        db=appdbs[i]
        cnxn = pyodbc.connect(r'Driver={SQL Server};Server=localhost;Database='+ db + r';Trusted_Connection=yes;')
        cursor = cnxn.cursor()
        cursor.execute("SELECT * FROM information_schema.routines WHERE ROUTINE_TYPE = 'PROCEDURE'")
        while 1:
            row = cursor.fetchone()
            if not row:
                break
            procName.append(db + "::" + row.ROUTINE_NAME.encode('ascii','ignore'))

    return locals()