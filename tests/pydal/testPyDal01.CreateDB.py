#!/usr/bin/env python3

from pydal import DAL, Field
from testPyDalSetup import getDB
from testPyDalSetup import *

# db = DAL('sqlite://test.db', folder='dbs')
# db = DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/pyDalDB01')
# db = getDBByName("BuildDbAdmin","Alt0ids76", "Refi", "host=localhost")
db = getDBByName("BuildDbAdmin","Alt0ids76", "Refi")
print db
db0 = getDB()
print db0
# db = DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/Refi')

try:
    db.define_table('cars', Field('name'), Field('price', type='integer'))
    db.cars.insert(name='Audi', price=52642)
    db.cars.insert(name='Skoda', price=9000)
    db.cars.insert(name='Volvo', price=29000)
    db.cars.insert(name='Bentley', price=350000)
    db.cars.insert(name='Citroen', price=21000)
    db.cars.insert(name='Hummer', price=41400)
    db.cars.insert(name='Volkswagen', price=21600)

finally:

    if db:
        db.close()