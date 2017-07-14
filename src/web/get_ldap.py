import sys

ldapId = sys.argv[0]

# Create the new LDAP repository
options = '-id ' + ldapId
AdminTask.getIdMgrRepository(options) 
