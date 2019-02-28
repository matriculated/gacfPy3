# -*- coding: utf-8 -*-
import traversalValidators
reload(traversalValidators)
import schemaUtilities
reload(schemaUtilities)


def index():
    dbname = request.get_vars.get('dbname', None)

    print("XXXXXZZZZZZZZZZZZZ")
    print(dbname + " " + str(DBREG))
    print("XXXXXZZZZZZZZZZZZZ")


    if not dbname in DBREG:
        redirect(URL(f='index'))
    database = DBREG[dbname]
    query = 'SELECT * FROM sys.tables ORDER BY [name] ASC'
    results = database.executesql(query, as_dict = True)
    return dict(results = results,dbname = dbname)
#END def index
