import pyodbc

# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=.\SQLEXPRESS;Database=myDB;Trusted_Connection=yes;')
# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=SQL2017;Database=AppAuth;Trusted_Connection=yes;')
cnxn = pyodbc.connect(r'Driver={SQL Server};Server=localhost;Database=PyodbcDb;Trusted_Connection=yes;')
cursor = cnxn.cursor()
cursor.execute("SELECT * FROM customer")
while 1:
    row = cursor.fetchone()
    if not row:
        break
    print(row.name + " " + str(row.age))


cnxn.execute("{CALL prcNoparms}")

params = (18, "Denille")
cnxn.execute("{CALL prcAgeNameInput (?,?)}", params)

# cnxn.close()

# cnxn = pyodbc.connect(r'Driver={SQL Server};Server=localhost;Database=PyodbcDb;Trusted_Connection=yes;')
# cursor = cnxn.cursor()
cursor.execute("SELECT * FROM customer Order by id")
while 1:
    row = cursor.fetchone()
    if not row:
        break
    print(row.name + " " + str(row.age))

# parmOut=""
# params = ("No", parmOut)
# x=cnxn.execute("{CALL prcOutputParms (?)}", params)
# print("1 " + x)
# print("2 " + params)


sql = """\
DECLARE @out nvarchar(max);
EXEC [dbo].[prcOutputParms] @param_in = ?, @param_out = @out OUTPUT;
SELECT @out AS the_output;
"""
params = ("Burma!", )
# cursor = cnxn.cursor()
cursor.execute(sql, params)
rows = cursor.fetchall()
while rows:
    print(rows)
    if cursor.nextset():
        rows = cursor.fetchall()
    else:
        rows = None

cnxn.close()




#-- SETUP DATABASE for Testing
# USE [master]
# GO

# /****** Object:  Database [PyodbcDb]    Script Date: 2/27/2019 3:48:03 PM ******/
# CREATE DATABASE [PyodbcDb]
#  CONTAINMENT = NONE
#  ON  PRIMARY 
# ( NAME = N'PyodbcDb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\PyodbcDb.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
#  LOG ON 
# ( NAME = N'PyodbcDb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\PyodbcDb_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
# GO

# ALTER DATABASE [PyodbcDb] SET COMPATIBILITY_LEVEL = 140
# GO

# IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
# begin
# EXEC [PyodbcDb].[dbo].[sp_fulltext_database] @action = 'enable'
# end
# GO

# ALTER DATABASE [PyodbcDb] SET ANSI_NULL_DEFAULT OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET ANSI_NULLS OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET ANSI_PADDING OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET ANSI_WARNINGS OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET ARITHABORT OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET AUTO_CLOSE OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET AUTO_SHRINK OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET AUTO_UPDATE_STATISTICS ON 
# GO

# ALTER DATABASE [PyodbcDb] SET CURSOR_CLOSE_ON_COMMIT OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET CURSOR_DEFAULT  GLOBAL 
# GO

# ALTER DATABASE [PyodbcDb] SET CONCAT_NULL_YIELDS_NULL OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET NUMERIC_ROUNDABORT OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET QUOTED_IDENTIFIER OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET RECURSIVE_TRIGGERS OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET  DISABLE_BROKER 
# GO

# ALTER DATABASE [PyodbcDb] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET DATE_CORRELATION_OPTIMIZATION OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET TRUSTWORTHY OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET ALLOW_SNAPSHOT_ISOLATION OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET PARAMETERIZATION SIMPLE 
# GO

# ALTER DATABASE [PyodbcDb] SET READ_COMMITTED_SNAPSHOT OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET HONOR_BROKER_PRIORITY OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET RECOVERY FULL 
# GO

# ALTER DATABASE [PyodbcDb] SET  MULTI_USER 
# GO

# ALTER DATABASE [PyodbcDb] SET PAGE_VERIFY CHECKSUM  
# GO

# ALTER DATABASE [PyodbcDb] SET DB_CHAINING OFF 
# GO

# ALTER DATABASE [PyodbcDb] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
# GO

# ALTER DATABASE [PyodbcDb] SET TARGET_RECOVERY_TIME = 60 SECONDS 
# GO

# ALTER DATABASE [PyodbcDb] SET DELAYED_DURABILITY = DISABLED 
# GO

# ALTER DATABASE [PyodbcDb] SET QUERY_STORE = OFF
# GO

# USE [PyodbcDb]
# GO

# ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
# GO

# ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
# GO

# ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
# GO

# ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
# GO

# ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
# GO

# ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
# GO

# ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
# GO

# ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
# GO

# ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
# GO

# ALTER DATABASE [PyodbcDb] SET  READ_WRITE 
# GO





#-- CREATE TABLE
# USE [PyodbcDb]
# GO

# /****** Object:  Table [dbo].[customer]    Script Date: 2/27/2019 3:46:35 PM ******/
# SET ANSI_NULLS ON
# GO

# SET QUOTED_IDENTIFIER ON
# GO

# CREATE TABLE [dbo].[customer](
# 	[id] [int] IDENTITY(1,1) NOT NULL,
# 	[name] [nvarchar](50) NOT NULL,
# 	[age] [int] NOT NULL
# ) ON [PRIMARY]
# GO
#
#

#-- Stored Procedure with no input params
# USE [PyodbcDb]
# GO
# /****** Object:  StoredProcedure [dbo].[prcNoParms]    Script Date: 2/27/2019 3:47:25 PM ******/
# SET ANSI_NULLS ON
# GO
# SET QUOTED_IDENTIFIER ON
# GO
# ALTER PROCEDURE [dbo].[prcNoParms]
# 	-- Add the parameters for the stored procedure here
# AS
# BEGIN
# 	-- SET NOCOUNT ON added to prevent extra result sets from
# 	-- interfering with SELECT statements.
# 	SET NOCOUNT ON;

#     -- Insert statements for procedure here
# 	SELECT 1, 'AA'
# END


#-- Stored Procedure for taking two input parameters  age (int), and name (string)
# USE [PyodbcDb]
# GO
# /****** Object:  StoredProcedure [dbo].[prcAgeNameInput]    Script Date: 2/27/2019 3:50:32 PM ******/
# SET ANSI_NULLS ON
# GO
# SET QUOTED_IDENTIFIER ON
# GO
# ALTER PROCEDURE [dbo].[prcAgeNameInput] 
# 	-- Add the parameters for the stored procedure here
# 	@age int = 0, @name nvarchar(50)
# AS
# BEGIN
# 	-- SET NOCOUNT ON added to prevent extra result sets from
# 	-- interfering with SELECT statements.
# 	SET NOCOUNT ON;

#     -- Insert statements for procedure here
# 	INSERT INTO dbo.customer (name, age) VALUES (@name, @age);  
# 	COMMIT
# END

#-- Stored procedures with one input parameter, and one output parameter
# USE [PyodbcDb]
# GO
# /****** Object:  StoredProcedure [dbo].[prcOutputParms]    Script Date: 2/27/2019 3:51:47 PM ******/
# SET ANSI_NULLS ON
# GO
# SET QUOTED_IDENTIFIER ON
# GO
# ALTER PROCEDURE [dbo].[prcOutputParms] 
#     @param_in nvarchar(max) = N'', 
#     @param_out nvarchar(max) OUTPUT
# AS
# BEGIN
#     SET NOCOUNT ON;

#     -- set output parameter
#     SELECT @param_out = N'Output parameter value: You said "' + @param_in + N'".';
    
#     -- also return a couple of result sets
#     SELECT N'SP result set 1, row 1' AS foo
#     UNION ALL
#     SELECT N'SP result set 1, row 2' AS foo;
    
#     SELECT N'SP result set 2, row 1' AS bar
#     UNION ALL
#     SELECT N'SP result set 2, row 2' AS bar;
# END


