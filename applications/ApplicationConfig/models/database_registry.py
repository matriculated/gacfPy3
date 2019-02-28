# -*- coding: utf-8 -*-
DBREG = {}
PROCREG = {}
def register(name, uri):
    if not name in DBREG:
        try:
            conn = DAL(uri, pool_size = 1, migrate_enabled = False, check_reserved = ['all'])
            DBREG[name] = conn
        except Exception as e:
            DBREG[name] = e

def registerProc(name, uri):
    if not name in DBREG:
        try:
            db = DAL(uri, pool_size = 1, migrate_enabled = False, check_reserved = ['all'])
            # db.conn()
            PROCREG[name] = conn
        except Exception as e:
            PROCREG[name] = e


# @auth.requires_login()
# def indexx():
     #response.flash = T("Hello World")
     #response.menu += [
     #    (T('My Sites'), False, URL('admin', 'default', 'site'))
     #]

import os.path 
    # x=os.getcwd()+'\..\models\database_registry.py.bak'
    # x=os.getcwd()+'\models\database_registry.py.bak'
x=os.getcwd()+ '\\applications\\' +request.application+'\models\database_registry.py.bak'
outfile=os.getcwd()+ '\\applications\\' +request.application+'\models\database_registry.py.out'
    # y=x + request.application
    # return 'ZZZ \>' + y + str(os.path.isfile(y)) + '\\' + request.application + ' \< ZZZ'
    #print(x)
    #return [os.path.dirname(os.path.abspath(__file__)),  " <".join(os.getcwd()).join(">> "), os.path.isfile(os.getcwd().join('/../models/database_registry.py.bak'))]
    # return [os.getcwd(), os.path.isfile(fname)]

from pydal import DAL, Field
    # DAL()
db=DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/master')
results=db.executesql('select * from sys.databases')
with open(outfile, 'w') as f:
    for row in results:
            # print row.name
            # f.write("%s\n" % str(row.name))
            # register('ApplicationConfiguration', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/ApplicationConfiguration')
        register(row.name, 'mssql4://BuildDbAdmin:Alt0ids76@localhost/' + row.name)

    # return 'ZZZ \>' + x + str(os.path.isfile(x)) + '\\' + request.application + ' \< ZZZ'
# return DBREG
    # return dict()
