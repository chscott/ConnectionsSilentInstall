import sys

icServer = sys.argv[0]
icJvmArgs = sys.argv[1]

server = AdminConfig.list('Server', icServer + '*') 
jvm = AdminConfig.list('JavaVirtualMachine', server)
existingJvmArgs = AdminConfig.showAttribute(jvm, 'genericJvmArguments')

if not existingJvmArgs.find(icJvmArgs) >= 0:
    print 'Updating JVM arguments'
    newJvmArgs = existingJvmArgs + ' ' + icJvmArgs
    AdminConfig.modify(jvm, [['genericJvmArguments', newJvmArgs]])
    AdminConfig.save()
else:
    print 'Will not update JVM arguments since required values already exist'
