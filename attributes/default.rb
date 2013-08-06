#
# Cookbook Name:: confluence
# Attributes:: confluence
#
# Copyright 2008-2011, Opscode, Inc.
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

# The openssl cookbook supplies the secure_password library to generate random passwords
::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default['confluence']['version']        = "4.3.7"
default['confluence']['checksum']       = "18602095e4119cc5498ac14b4b5588e55f707cca73b36345b95c9a9e4c25c34d"
default['confluence']['install_path']   = "/srv/confluence"
default['confluence']['data_dir']       = "#{node['confluence']['install_path']}/data"
default['confluence']['init_style']     = "runit"
default['confluence']['run_user']       = "atlassian"
default['confluence']['server_port']    = "8001"
default['confluence']['connector_port'] = "8081"
default['confluence']['database_type']  = "mysql"
# The mysql cookbook binds to ipaddress by default. Add this to the role.
#  "override_attributes": {
#    "mysql": {
#      "bind_address": "127.0.0.1"
#    }
default['confluence']['database_host']        = "localhost"
default['confluence']['database_user']        = "confluence"
default['confluence']['database_name']        = "confluence"
set_unless['confluence']['database_password'] = secure_password

default['confluence']['virtual_host_name']  = "confluence.#{node['domain']}"
default['confluence']['virtual_host_alias'] = "confluence.#{node['domain']}"

# Use the JAVA_OPTS from Atlassian's default setenv.sh script. Be sure
# to include the trailing space!!
default['confluence']['java_opts'] = "-Xms256m -Xmx512m -XX:MaxPermSize=256m $JAVA_OPTS -Djava.awt.headless=true "

# Confluence doesn't support OpenJDK http://jira.atlassian.com/browse/CONF-16431
# This is a normal attribute (set) because we want to override
# the attribute from the java cookbook itself. However, we cannot set
# the attribute to accept the license terms here, so the user must set
# that (e.g. in a role).
set['java']['install_flavor'] = "oracle"

case node['platform_family']
when 'debian'
  default['confluence']['plugin_dependencies'] = %w{libice-dev libsm-dev libx11-dev libxext-dev libxp-dev libxt-dev libxtst-dev}
when 'redhat'
  default['confluence']['plugin_dependencies'] = %w{libICE-devel libSM-devel libX11-devel libXext-devel libXp-devel libXt-devel libXtst-devel}
else
  default['confluence']['plugin_dependencies'] = %w{libice-dev libsm-dev libx11-dev libxext-dev libxp-dev libxt-dev libxtst-dev}
end
