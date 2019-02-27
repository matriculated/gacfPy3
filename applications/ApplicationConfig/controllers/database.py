# -*- coding: utf-8 -*-
def dbschema():
    return DBREG


def index():
    indexx()
    keys = []
    for k,v in list(DBREG.items()):
        if not isinstance(v, Exception):
            keys.append(k)
    return dict(databaseNames = keys)
#END def index
