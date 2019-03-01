procList=['ApplicationConfiguration::uspGetAddress', 'PyodbcDb::prcOutputParms', 'PyodbcDb::prcAgeNameInput', 'PyodbcDb::prcNoParms'] 

for i in range(len(procList)):
    # print(procList[i])
    proc = procList[i].split('::')
    print(proc[0])
    print(proc[1])