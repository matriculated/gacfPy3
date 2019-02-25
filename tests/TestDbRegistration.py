from pydal import DAL, Field

DBREG = {}
def register(name, uri):
    from pydal import DAL, Field
    if not name in DBREG:
        try:
            conn = DAL(uri, pool_size = 1, migrate_enabled = False, check_reserved = ['all'])
            DBREG[name] = conn
        except Exception as e:
            DBREG[name] = e


def index():
    keys = []
    for k,v in list(DBREG.items()):
        if not isinstance(v, Exception):
            keys.append(k)
    return dict(databaseNames = keys)

#register('credit-service', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/CreditService')
#register('payment-service', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/Payments')
# register('Credit', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/Credit')
register('AppAuth', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/AppAuth')
register('ApplicationConfiguration', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/ApplicationConfiguration')
index()
print(DBREG)



