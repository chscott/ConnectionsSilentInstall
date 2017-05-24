import sys

options = sys.argv[0]

generator = AdminControl.completeObjectName('type=PluginCfgGenerator,*')

AdminControl.invoke(generator, 'propagateKeyring', options) 
