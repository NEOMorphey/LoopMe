#Default Definitions For project
default['deploy']['sitename'] = "project"
default['deploy']['dir']="/var/www/project"
default['deploy']['username']="www-data" #User from what run nginx
default['deploy']['syncip']="172.17.16.54" #IP Address of slave node without unison
default['deploy']['passwd']="password" #Root password on slave node
default['deploy']['master']= false
default['deploy']['minutes']="30" #Sync folders every XX minutes
default['deploy']['initialsync']=true #Should we sync files at the setup time