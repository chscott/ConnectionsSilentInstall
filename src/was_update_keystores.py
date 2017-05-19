import sys

icCertHost = sys.argv[0]
icCertPort = sys.argv[1]
icCertAlias = sys.argv[2]
plgCertScope = sys.argv[3]
plgCertStore = sys.argv[4]

# Get the certificate from the Connections app server 
options = '-host ' + icCertHost + ' ' + \
          '-port ' + icCertPort + ' ' + \
          '-certificateAlias ' + icCertAlias + ' ' + \
          '-keyStoreScope ' + plgCertScope + ' ' + \
          '-keyStoreName ' + plgCertStore
AdminTask.retrieveSignerFromPort(options) 

# Save the configuration
AdminConfig.save()
