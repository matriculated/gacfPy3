def getDB():
    return "DB" + "1xxxx1"

def getDBByName(Usr, Ps, Db, *parameters, **keywords):
    from pydal import DAL
    # url = DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/Refi')    

    if ('host' in keywords):
          print('optional parameter found, it is ', keywords['host'])
          Hst = keywords['host']
    else:
          print('host = localhost')
          Hst = 'localhost'

    url = 'mssql4://'+Usr + ':' + Ps + '@' + Hst + '/' + Db
    print (url)
    url = DAL(url)    
    return url    
