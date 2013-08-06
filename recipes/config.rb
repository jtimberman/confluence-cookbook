#
# Cookbook Name:: confluence
# Recipe:: config
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

cookbook_file "#{node['confluence']['install_path']}/confluence-#{node['confluence']['version']}/bin/startup.sh" do
  owner node['confluence']['run_user']
  group node['confluence']['run_user']
  source "startup.sh"
  mode 0755
  notifies :restart, "service[confluence]"
end

template "#{node['confluence']['install_path']}/confluence-#{node['confluence']['version']}/bin/setenv.sh" do
  owner node['confluence']['run_user']
  group node['confluence']['run_user']
  source "setenv.sh.erb"
  mode 0755
  notifies :restart, "service[confluence]"
end

template "#{node['confluence']['install_path']}/confluence-#{node['confluence']['version']}/conf/server.xml" do
  owner node['confluence']['run_user']
  group node['confluence']['run_user']
  source "server.xml.erb"
  mode 0644
  notifies :restart, "service[confluence]"
end

template "#{node['confluence']['install_path']}/confluence-#{node['confluence']['version']}/confluence/WEB-INF/classes/confluence-init.properties" do
  owner node['confluence']['run_user']
  group node['confluence']['run_user']
  source "confluence-init.properties.erb"
  mode 0644
  notifies :restart, "service[confluence]"
end
