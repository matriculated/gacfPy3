#!/usr/bin/env python3

from pydal import DAL, Field
from testPyDalSetup import getDB
from testPyDalSetup import *

# db = DAL('sqlite://test.db', folder='dbs')
# db = DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/pyDalDB01')
# db = getDBByName("BuildDbAdmin","Alt0ids76", "Refi", "host=localhost")
db = getDBByName("BuildDbAdmin","Alt0ids76", "Refi")
print(dbr)
db0 = getDB()
print(db0)
# db = DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/Refi')

try:
    db.executesql("CREATE PROCEDURE getCarLike @NAME varchar(100)AS SELECT * FROM dbo.cars where name LIKE @NAME;")

finally:

    if db:
        db.close()
