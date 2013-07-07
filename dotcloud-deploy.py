import os

def dotcloudDeploy(name):
  print ''
  os.system("dotcloud connect " + name)
  os.system("dotcloud push")

print ''
print ''
print '------------------------------------------'
print 'Select a dotcloud instance to run this for'
print '1) Bowling'
print '2) Golf'
print '3) Commentary'
print '4) Pandora'
print '5) Television'
print '6) NextStudio'
print '7) StandUp'
print '8) (All)'
print '------------------------------------------'
print ''
print ''

instance = int(raw_input())

if instance == 1:
  dotcloudDeploy('lpbowling')
elif instance == 2:
  dotcloudDeploy('lpgolf')
elif instance == 3:
  dotcloudDeploy('lpcommentary')
elif instance == 4:
  dotcloudDeploy('lppandora')
elif instance == 5:
  dotcloudDeploy('lptelevision')
elif instance == 6:
  dotcloudDeploy('nextstudio')
elif instance == 7:
  dotcloudDeploy('lpstandup')
elif instance == 8:
  dotcloudDeploy('lpbowling')
  dotcloudDeploy('lpgolf')
  dotcloudDeploy('lpcommentary')
  dotcloudDeploy('lppandora')
  dotcloudDeploy('lptelevision')
  dotcloudDeploy('nextstudio')
  dotcloudDeploy('lpstandup')
else:
  print "You entered an invalid value"