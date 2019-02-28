from pydal import DAL, Field

# db = DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/PyOdbcDb')
db = DAL('mssql://Driver={SQL Server};Server=localhost;Database=master;Trusted_Connection=yes;')
results=db.executesql("select name from sys.databases")

print(results)