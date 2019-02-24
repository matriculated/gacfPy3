# -*- coding: utf-8 -*-
from . import schemaUtilities
reload(schemaUtilities)

class traversalValidators:
    @staticmethod
    def validateTableName(database, value):
        query = 'SELECT * FROM sys.tables WHERE [name] = ?'
        results = database.executesql(query, (value,), as_dict = True)
        if len(results) == 0:
            return False
        return True
    #END def validateTableName

    @staticmethod
    def getRecordById(database, table, value):
        index = schemaUtilities.schemaUtilities.getPrimaryKey(database, table)
        index = index['name']
        if index == None:
            raise NotImplementedError('Cannot use unique key yet.')
        query = 'SELECT * FROM ' + table + ' WHERE ' + index + ' = ?'
        results = database.executesql(query, (value,), as_dict = True)
        if len(results) == 0:
            return False
        return results[0]
    #END def validateRecordId
#END class traversalValidators
