# -*- coding: utf-8 -*-
DBREG = {}
def register(name, uri):
    if not name in DBREG:
        try:
            conn = DAL(uri, pool_size = 1, migrate_enabled = False, check_reserved = ['all'])
            DBREG[name] = conn
        except Exception as e:
            DBREG[name] = e

#register('credit-service', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/CreditService')
#register('payment-service', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/Payments')
#register('Credit', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/Credit')
#register('PLADSS', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/PLADSS')
#register('Guardian', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/Guardian')
#register('ChangeSend', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/ChangeSend')
#register('LoanTypeService', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/LoanTypeService')
register('ApplicationConfiguration', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/ApplicationConfiguration')
