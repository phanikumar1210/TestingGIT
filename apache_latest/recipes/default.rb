#
# Cookbook Name:: apacheinstall
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

=begin
package "java" do
	action:upgrade
end
cookbook_file '/opt/apache-tomcat-7.0.64.tar.gz' do
	source 'apache-tomcat-7.0.64.tar.gz'
	owner 'root'
	group 'root'
	mode '0777'
	not_if do ::File.exists?('/opt/apache-tomcat-7.0.64') end
end
cookbook_file '/opt/apache-tomcat-8.0.24.tar.gz' do
	source 'apache-tomcat-8.0.24.tar.gz'
	owner 'root'
	group 'root'
	mode '0777'
	not_if do ::File.exists?('/opt/apache-tomcat-7.0.64') end
end
execute 'apache_install1' do
	command <<-EOH
		tar xvzf /opt/apache-tomcat-8.0.24.tar.gz
		mv /apache-tomcat-8.0.24 /opt/
	EOH
	not_if do ::File.exists?('/opt/apache-tomcat-7.0.64') end
end
execute 'apache_install' do
	command <<-EOH
		tar xvzf /opt/apache-tomcat-7.0.64.tar.gz
		mv /apache-tomcat-7.0.64 /opt/
	EOH
	not_if do ::File.exists?('/opt/apache-tomcat-7.0.64') end
end
=end
remote_file '/opt/apache-tomcat-7.0.64.tar.gz' do
	source "file://#{Chef::Config['file_cache_path']}/cookbooks/#{cookbook_name}/files/default/apache-tomcat-7.0.64.tar.gz"
	owner 'root'
	group 'root'
	mode '0777'
	action :create_if_missing
end
execute 'apache_install' do
	command <<-EOH
		tar xvfz #{node['apache_zipped_file_name']}
	EOH
	cwd '/opt/'
	not_if do ::File.exists?("/opt/#{node['apache_unzipped_file_name']}") end
end
cookbook_file "/opt/#{node['apache_unzipped_file_name']}/conf/tomcat-users.xml" do
	source 'tomcat-users.xml'
	owner 'root'
	group 'root'
	mode '0777'
end
ruby_block 'SI_Install_DB_NON_AUTOMATIC' do
    block do
        if File.readlines("/opt/#{node['apache_unzipped_file_name']}/conf/server.xml").grep(/^(.*)<Connector port="8080" protocol=\"HTTP\/1.1\"(.*)$/).size> 0
        fe=Chef::Util::FileEdit.new("/opt/#{node['apache_unzipped_file_name']}/conf/server.xml")
        fe.search_file_replace_line(/^(.*)<Connector port=\"8080\" protocol=\"HTTP\/1.1\"(.*)$/,"<Connector port=\"80\" protocol=\"HTTP\/1.1\"")
        fe.write_file
        end
    end
end
=begin
cookbook_file "/opt/#{node['apache_unzipped_file_name']}/conf/server.xml" do
	source 'server.xml'
	owner 'root'
	group 'root'
	mode '0777'
end
=end
execute 'apache_start' do
	command "/opt/#{node['apache_unzipped_file_name']}/bin/shutdown.sh"
	command "/opt/#{node['apache_unzipped_file_name']}/startup.sh"
	ignore_failure true
end
cookbook_file "/opt/#{node['apache_unzipped_file_name']}/webapps/ROOT/index.jsp" do
	source 'index.jsp'
	owner 'root'
	group 'root'
	mode '0644'
end
log "Installing Apache Tomcat 7.0.64 has completed successfully" do
  level :info
  action :write
end
=begin
	<tomcat-users>
	<role rolename="admin-gui"/>
	<user username="admin" password="password" roles="admin-gui">
	<role rolename="manager-gui"/>
	<user username="user" password="password" roles="manager-gui"/>
	</tomcat-users>
=end