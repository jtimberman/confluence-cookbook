#
# Cookbook Name:: confluence
# Recipe:: mysql
#
# Copyright 2011-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
return unless node['confluence']['database_type'] == 'mysql'

# These values don't always come from attributes.
mysql_root_password = node['mysql']['server_root_password']
mysql_host = node['confluence']['database_host']

# mysql should be running
if mysql_host == "localhost"
  include_recipe "mysql::server"

  # Assume a local mysql server isn't clustered and should be running
  service "mysql" do
    action :start
  end
  mysql_grant_host = mysql_host
else
  mysql_grant_host = node['ipaddress']
end

include_recipe "mysql::ruby"

ruby_block "Create database + execute grants" do
  block do
    require 'mysql'

    m = Mysql.new(mysql_host, "root", mysql_root_password)
    if !m.list_dbs.include?(node['confluence']['database_name'])
      # Create the database
      Chef::Log.debug "Creating mysql database #{node['confluence']['database_name']}"
      m.query("CREATE DATABASE #{node['confluence']['database_name']} CHARACTER SET utf8")
    end

    # Grant and flush permissions
    Chef::Log.debug "Granting access to #{node['confluence']['database_name']} for #{node['confluence']['database_user']}"
    m.query("GRANT ALL ON #{node['confluence']['database_name']}.* TO '#{node['confluence']['database_user']}'@'#{mysql_grant_host}' IDENTIFIED BY '#{node['confluence']['database_password']}'")
    m.reload
  end
end
