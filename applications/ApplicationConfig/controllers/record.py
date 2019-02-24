# -*- coding: utf-8 -*-
import traversalValidators
reload(traversalValidators)
import schemaUtilities
reload(schemaUtilities)

def index():
    dbname = request.get_vars.get('dbname',None)
    if dbname not in DBREG:
        redirect(URL(c = 'database', f = 'index'))
    database = DBREG[dbname]
    table_name = request.get_vars.get('tablename',None)
    if not traversalValidators.traversalValidators.validateTableName(database, table_name):
        redirect(URL(controller = 'database', f = 'view', vars = dict(dbname = dbname)))
    query = 'SELECT * FROM ' + table_name
    results = database.executesql(query, as_dict = True)
    pkey = schemaUtilities.schemaUtilities.getPrimaryKey(database, table_name)
    return dict(results = results, dbname = dbname, tablename = table_name, pkey = pkey['name'])
#END def view

def edit():
    dbname = request.get_vars.get('dbname', None)
    if dbname not in DBREG:
        redirect(URL(c = 'database', f = 'index'))
    database = DBREG[dbname]
    table_name = request.get_vars.get('tablename',None)
    if not traversalValidators.traversalValidators.validateTableName(database, table_name):
        redirect(URL(c = 'database', f = 'view', vars = dict(dbname = dbname)))
    record_id = request.get_vars.get('recordid',None)
    pkey = schemaUtilities.schemaUtilities.getPrimaryKey(database, table_name)
    fkeys = schemaUtilities.schemaUtilities.getForeignKeys(database, table_name)
    record = traversalValidators.traversalValidators.getRecordById(database, table_name, record_id)
    if record == False:
        redirect(URL(c = 'table', f = 'index', vars = dict(dbname = dbname, tablename = table_name)))
    form = FORM()
    if form.accepts(request, session):
        query = 'UPDATE ' + table_name + ' SET '
        args = []
        for k,v in list(request.post_vars.items()):
            if k in ['submit', '_formkey', '_formname', pkey['name']]:
                continue
            query += k + ' = ?, '
            args.append(v)
        query = query[:-2] + ' WHERE ' + pkey['name'] + ' = ?'
        args.append(record_id)
        database.executesql(query, args)
        record = traversalValidators.traversalValidators.getRecordById(database, table_name, record_id)
    return dict(
        record = record,
        form = form,
        dbname = dbname,
        tablename = table_name,
        recordid = record_id,
        pkey = pkey,
        fkeys = fkeys
    )
#END def view

def add():
    dbname = request.get_vars.get('dbname', None)
    if dbname not in DBREG:
        redirect(URL(c = 'database', f = 'index'))
    database = DBREG[dbname]
    table_name = request.get_vars.get('tablename',None)
    if not traversalValidators.traversalValidators.validateTableName(database, table_name):
        redirect(URL(c = 'database', f = 'view', vars = dict(dbname = dbname)))
    pkey = schemaUtilities.schemaUtilities.getPrimaryKey(database, table_name)
    fkeys = schemaUtilities.schemaUtilities.getForeignKeys(database, table_name)
    query = '''
      SELECT c.name
      FROM sys.tables t
      JOIN sys.all_columns c ON t.object_id = c.object_id
      WHERE t.name = ?
    '''
    columns = database.executesql(query, (table_name,), as_dict = True)
    form = FORM()
    if form.accepts(request, session):
        query = 'INSERT INTO ' + table_name + ' VALUES '
        #query +=
    return dict(
        columns = columns,
        form = form,
        dbname = dbname,
        tablename = table_name,
        pkey = pkey,
        fkeys = fkeys
    )
#END def view

def search():
    TYPEWEIGHTS = dict(
            bigint=2,
            int=2,
            smallint=2,
            bit=1,
            varchar=1,
            char=1
    )
    dbname = request.get_vars.get('dbname', None)
    if dbname not in DBREG:
        raise HTTP(400, "Invalid dbname")
    database = DBREG[dbname]
    tablename = request.get_vars.get('tablename', None)
    if not traversalValidators.traversalValidators.validateTableName(database, tablename):
        raise HTTP(400, "Invalid tablename")
    form = FORM(
            INPUT(_name = 'SearchTerms', requires = IS_NOT_EMPTY()),
            INPUT(_name = 'Search', _type='submit', _value='Search'),
            _method="POST",
            _action=URL(vars = dict(dbname = dbname, tablename = tablename))
    )
    results = list()
    record = None
    if form.process(formname = 'search').accepted:
        query = '''
          SELECT 
            c.name AS [name],
            t2.name AS [type]
          FROM sys.tables t
          JOIN sys.all_columns c ON t.object_id = c.object_id
          JOIN sys.types t2 ON t2.system_type_id = c.system_type_id
          WHERE t.name = ?
        '''
        columns = database.executesql(query, (tablename,), as_dict = True)
        pkey = schemaUtilities.schemaUtilities.getPrimaryKey(database, tablename)
        terms = form.vars.SearchTerms.strip().split(' ')
        for term in terms:
            term = term.strip()
            if term == '':
                continue
            args = []
            query = 'WITH agg(id,[weight]) AS ('
            for column in columns:
                if column['type'] in ['int','bigint','smallint','bit']:
                    try:
                        casted_term = int(term)
                    except:
                        continue
                else:
                    casted_term = term
                if column['type'] not in ['datetime2','date']:
                    if column['name'] == pkey['name']:
                        weight = 100
                    else:
                       weight = TYPEWEIGHTS[column['type']]
                    query += 'SELECT %s,%i FROM %s WHERE %s' % (pkey['name'], weight, tablename, column['name'])
                    if column['type'] in ['varchar']:
                        try:
                            args.append('%'+casted_term+'%')
                        except:
                            raise Exception(column,casted_term)
                        query += ' LIKE ?'
                    else:
                        args.append(casted_term)
                        query += ' = ?'
                    query += ' UNION ALL '
            query = query[:-11]
            query += ''') 
                SELECT
                    id,
                    SUM([weight]) AS [weight]
                FROM agg
                GROUP BY id 
            '''
            answers = database.executesql(query, tuple(args), as_dict = True)
            count = 0
            for answer in answers:
                if count >= len(results):
                    results.append(dict(id = answer['id'], weight = 0))
                results[count]['weight'] += answer['weight']
                count += 1
        results.sort(key=lambda x:x['weight'], reverse=True)
        record = []
        if len(results) > 0:
            record = database.executesql('SELECT * FROM '+tablename+' WHERE '+pkey['name']+' = ?', (results[0]['id'],), as_dict = True)
        if len(record) > 0:
            record = record[0]
        else:
            record = None
    return dict(form = form,record = record)
#END def search

def get():
    return dict()
    dbname = request.get_vars.get('dbname', None)
    if dbname not in DBREG:
        raise HTTP(400, "Invalid dbname")
    database = DBREG[dbname]
    tablename = request.get_vars.get('tablename', None)
    if not traversalValidators.traversalValidators.validateTableName(database, tablename):
        raise HTTP(400, "Invalid tablename")
    recordid = request.get_vars.get('recordid', None)
    record = traversalValidators.traversalValidators.getRecordById(database, tablename, recordid)
    if record == False:
        raise HTTP(400, 'Invalid recordid')
    return record
#END def get
