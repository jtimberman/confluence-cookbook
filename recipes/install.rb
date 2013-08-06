#
# Cookbook Name:: confluence
# Recipe:: install
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

include_recipe "java::#{node['java']['install_flavor']}"

# X11 dependencies for graphic libraries for thumbnailing, pdf export, etc
node['confluence']['plugin_dependencies'].each do |pack|
  package pack
end

ark "confluence" do
  path node['confluence']['install_path']
  prefix_root node['confluence']['install_path']
  version node['confluence']['version']
  checksum node['confluence']['checksum']
  url "http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-#{node['confluence']['version']}.tar.gz"
  owner node['confluence']['run_user']
  group node['confluence']['run_user']
  notifies :run, "execute[configure file permissions]", :immediately
  action :install
  # the checksum doesn't seem to be honored, causing a download on
  # every run, but we can check that the symbolic link is set to point
  # at the correct version (per the version attribute).
  not_if do
    ::File.readlink(::File.join(node['confluence']['install_path'], "current")) ==
      "#{node['confluence']['install_path']}/confluence-#{node['confluence']['version']}"
  end
end

link ::File.join(node['confluence']['install_path'], "current") do
  to "#{node['confluence']['install_path']}/confluence-#{node['confluence']['version']}"
end

directory "#{node['confluence']['data_dir']}-#{node['confluence']['version']}" do
  owner node['confluence']['run_user']
  group node['confluence']['run_user']
end

link node['confluence']['data_dir'] do
  to "#{node['confluence']['data_dir']}-#{node['confluence']['version']}"
end

execute "configure file permissions" do
  command "chown -R #{node['confluence']['run_user']} #{node['confluence']['install_path']}"
  action :nothing
end
