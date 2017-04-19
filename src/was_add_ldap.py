import sys

ldapType = sys.argv[0]
ldapId = sys.argv[1]
ldapHost = sys.argv[2]
ldapPort = sys.argv[3]
ldapBindDn = sys.argv[4]
ldapBindPwd = sys.argv[5]
ldapBase = sys.argv[6]
loginProperties = sys.argv[7]
realmName = sys.argv[8]

# Create the new LDAP repository
options = '-ldapServerType ' + ldapType + ' ' + \
          '-id ' + ldapId + ' ' + \
          '-loginProperties ' + loginProperties + ' ' + \
          '-default true'
AdminTask.createIdMgrLDAPRepository(options) 

# Add an LDAP server to the LDAP repository
options = '-ldapServerType ' + ldapType + ' ' + \
          '-id ' + ldapId + ' ' + \
          '-host ' + ldapHost + ' ' + \
          '-port ' + ldapPort + ' ' + \
          '-bindDN ' + ldapBindDn + ' ' + \
          '-bindPassword ' + ldapBindPwd 
AdminTask.addIdMgrLDAPServer(options)

# Add base entries for the LDAP repository
options = '-id ' + ldapId + ' ' + \
          '-name ' + ldapBase + ' ' + \
          '-nameInRepository ' + ldapBase
AdminTask.addIdMgrRepositoryBaseEntry(options)

# Link the LDAP repository to the realm
options = '-baseEntry ' + ldapBase + ' ' + \
          '-name ' + realmName
AdminTask.addIdMgrRealmBaseEntry(options)

# Save the configuration
AdminConfig.save()
