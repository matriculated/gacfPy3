# -*- coding: utf-8 -*-

class schemaUtilities:
    @staticmethod
    def getPrimaryKey(database, tablename):
        query = '''
            SELECT ac.name
            FROM sys.indexes AS i
            JOIN sys.tables AS t 
                ON t.object_id = i.object_id
            JOIN sys.index_columns AS ic
                ON ic.object_id = i.object_id
                AND ic.index_id = i.index_id
            JOIN sys.all_columns AS ac
                ON ac.object_id = i.object_id
                AND ac.column_id = ic.column_id
            WHERE t.[name] = ? 
                AND i.is_primary_key = 1
        '''
        primary_key = database.executesql(query, (tablename,), as_dict = True)
        if len(primary_key) > 0:
            return primary_key[0]
        return None
    #END def getPrimaryKey

    @staticmethod
    def getForeignKeys(database, tablename):
        query = '''
            SELECT 
            	p.name AS [Parent Name]
           		,pc.name AS [Parent Column Name]
       			,c.name AS [Referenced Name]
       			,cc.name AS [Referenced Column Name]
       		FROM sys.foreign_keys AS fk
       		JOIN sys.foreign_key_columns AS fkc
       			ON fkc.constraint_object_id = fk.object_id
       		JOIN sys.tables AS p
       			ON p.object_id = fk.parent_object_id
       			AND p.name = ?
       		JOIN sys.tables AS c
       		    ON c.object_id = fk.referenced_object_id
       		JOIN sys.all_columns AS pc
       			ON pc.object_id = p.object_id
       			AND pc.column_id = fkc.parent_column_id
       		JOIN sys.all_columns AS cc
       			ON cc.object_id = c.object_id
       			AND cc.column_id = fkc.referenced_column_id
        '''
        foreign_keys = database.executesql(query, (tablename,), as_dict = True)
        fkeys = dict()
        for key in foreign_keys:
            pcn = key.pop('Parent Column Name')
            fkeys[pcn] = key
        return fkeys
    #END def getPrimaryKey
#END class schemaUtilities
