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
