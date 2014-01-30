#
# Cookbook Name:: deploy
# Recipe:: default
#
# Copyright 2014, NEOMorphey
#
# All rights reserved - Do Not Redistribute
#
package "nginx"
package "unison"
package "sshpass"

template "/etc/nginx/nginx.conf" do
	           owner "root"
	           group "root"
	           mode "0644"
	           source "nginx.conf.erb"
	        end
directory "#{node['deploy']['dir']}" do
	owner "#{node['deploy']['username']}"
	group "#{node['deploy']['username']}"
	mode  "0755"
	action :create
end

file "/etc/nginx/sites-available/default" do
	action :delete
end

link "/etc/nginx/sites-enabled/default" do
	action :delete
end

template "/etc/nginx/sites-available/#{node['deploy']['sitename']}" do
    owner "root"
    group "root"
    mode "0664"
    source "host.conf.erb"
end
link "/etc/nginx/sites-enabled/#{node['deploy']['sitename']}" do
    to "/etc/nginx/sites-available/#{node['deploy']['sitename']}"
end

service "nginx" do
	supports [:status]
	     action :restart
end

#Working with ssh Generating ssh keys for sync
script "generate_keys" do
	        interpreter "bash"
	        user "root"
	        cwd "/root"
	        code <<-EOH
	        ssh-keygen -t rsa -q -f /root/.ssh/id_rsa -P \"\"
	        EOH
	end
if node['deploy']['master']
	script "add_known_hosts" do
		interpreter "bash"
		        user "root"
		        cwd "/root"
		        code <<-EOH
		        ssh-keyscan -H #{node['deploy']['syncip']} >> /root/.ssh/known_hosts
		        EOH
	end

	script "copy_key_to_sync_slave" do
		interpreter "bash"
		        user "root"
		        cwd "/root"
		        code <<-EOH
		        sshpass -p #{node['deploy']['passwd']} ssh-copy-id -i /root/.ssh/id_rsa.pub root@#{node['deploy']['syncip']}
		        EOH
	end
	directory "/root/.unison" do
		owner "root"
		group "root"
		mode  "0700"
		action :create
	end
	template "/root/.unison/sync" do
	    owner "root"
	    group "root"
	    mode "0664"
	    source "unison.conf.erb"
	end
	cron "add_unison_to_cron" do
		minute "*/#{node['deploy']['minutes']}"
		hour "*"
  		day "*"
		month "*"
 		weekday "*"
 		command "unison sync"
 		action :create
 	end
 	if node['deploy']['initialsync']
 		script "unison_sync" do
		interpreter "bash"
		        user "root"
		        cwd "/root"
		        code <<-EOH
		        unison sync
		        EOH
		end
	end
end