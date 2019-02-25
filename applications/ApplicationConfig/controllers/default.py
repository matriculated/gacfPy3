# -*- coding: utf-8 -*-

# # @auth.requires_login()
import os.path 
from pydal import DAL, Field

def index():
    x=os.getcwd()+ '\\applications\\' +request.application+'\models\database_registry.py.bak'
    outfile=os.getcwd()+ '\\applications\\' +request.application+'\models\database_registry.py.out'

    db=DAL('mssql4://BuildDbAdmin:Alt0ids76@localhost/master')
    results=db.executesql('select * from sys.databases')
    with open(outfile, 'w') as f:
        for row in results:
            # print row.name
            # f.write("%s\n" % str(row.name))
            # register('ApplicationConfiguration', 'mssql4://BuildDbAdmin:Alt0ids76@localhost/ApplicationConfiguration')
            register(row.name, 'mssql4://BuildDbAdmin:Alt0ids76@localhost/' + row.name)

    # return 'ZZZ \>' + x + str(os.path.isfile(x)) + '\\' + request.application + ' \< ZZZ'
    return DBREG
    # return dict()

# import schemaUtilities
# reload(schemaUtilities)
# def index():
#     # from schemaUtilities import schemaUtilities
#     x = schemaUtilities.schemaUtilities.setUp()
#     # a=schemaUtilities()
#     # a.schemaUtilities.setup()

@auth.requires_login()
def api_get_user_email():
    if not request.env.request_method == 'GET': raise HTTP(403)
    return response.json({'status':'success', 'email':auth.user.email})

@auth.requires_membership('admin') # can only be accessed by members of admin groupd
def grid():
    response.view = 'generic.html' # use a generic view
    tablename = request.args(0)
    if not tablename in db.tables: raise HTTP(403)
    grid = SQLFORM.smartgrid(db[tablename], args=[tablename], deletable=False, editable=False)
    return dict(grid=grid)

# ---- Embedded wiki (example) ----
def wiki():
    auth.wikimenu() # add the wiki to the menu
    return auth.wiki() 

# ---- Action for login/register/etc (required for auth) -----
def user():
    """
    exposes:
    http://..../[app]/default/user/login
    http://..../[app]/default/user/logout
    http://..../[app]/default/user/register
    http://..../[app]/default/user/profile
    http://..../[app]/default/user/retrieve_password
    http://..../[app]/default/user/change_password
    http://..../[app]/default/user/bulk_register
    use @auth.requires_login()
        @auth.requires_membership('group name')
        @auth.requires_permission('read','table name',record_id)
    to decorate functions that need access control
    also notice there is http://..../[app]/appadmin/manage/auth to allow administrator to manage users
    """
    return dict(form=auth())

# ---- action to server uploaded static content (required) ---
@cache.action()
def download():
    """
    allows downloading of uploaded files
    http://..../[app]/default/download/[filename]
    """
    return response.download(request, db)

