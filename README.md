# confluence cookbook

This cookbook performs an opinionated installation of Atlassian
Confluence standalone from .tar.gz, manages various
configuration files, and starts confluence as a service under
[runit](http://smarden.org/runit).

It is not a goal of this cookbook to support every combination of
Confluence installation. The recipes are designed to be modular
components to cover common use cases, but it is currently out of scope
to try to support multiple different kinds of databases or init /
service management systems. It is also out of scope to provide a
reverse proxy for the service.

It does not manage your Confluence license; the initial setup wizard
will be available once the service is running.

# Requirements

Requires Chef 11+.

## Platform

* Ubuntu (10.04, 12.04)

This cookbook may work on other platforms with or without
modification. Attributes are available to override in a role if
required.

## Cookbooks

From community.opscode.com:

* openssl
* runit
* java
* mysql
* ark

These are defined as dependencies in the metadata.

# Attributes

See `attributes/default.rb` for default values.

* `node['confluence']['version']` - The version of Confluence to install.
* `node['confluence']['checksum']` - SHA256 checksum of the Confluence tar.gz.
* `node['confluence']['install_path']` - Base directory where
  Confluence lives, default `/srv/confluence`. A version specific
  directory will be created and a symlink made to `/srv/confluence/current`.
* `node['confluence']['data_dir']` - The `confluence.home` directory.
  A version specific directory will be created, and a symlink made to
  `/srv/confluence/data`.
* `node['confluence']['init_style']` - The init system used to manage
  the Confluence application service. Default is `runit`.
* `node['confluence']['run_user']` - The user that will own the
  confluence installation and that the application will run as.
  Default is `atlassian`, so that other Atlassian products can share
  this user when running on the same system.
* `node['confluence']['server_port']` - Server port for Confluence's
  Tomcat configuration, not user-facing, but required. Only change
  this if there is a conflict with the default, `8001`.
* `node['confluence']['connector_port']` - The port that confluence will
  be available on, e.g., "confluence.example.com:8081". A reverse
  proxy can be set up in front of this, but that is out of scope for
  this cookbook.
* `node['confluence']['virtual_host_name']` - Preserved for backwards
  compatibility, used in Apache configuration for a VirtualHost, but
  out of scope for the current version of this cookbook.
* `node['confluence']['virtual_host_alias']` - Preserved for backwards
  compatibility, used in Apache configuration for a VirtualHost, but
  out of scope for the current version of this cookbook.
* `node['confluence']['java_opts']` - used as `$JAVA_OPTS` for the
  setenv.sh script. **IMPORTANT** Be sure to include a trailing space
  when overriding this.
* `node['confluence']['plugin_dependencies']` - Additional package
  that are dependencies for Confluence plugins. This is platform
  specific. Default values are set for Debian and RHEL family Linux
  distributions.

### Database Attributes

* `node['confluence']['database_type']` - The type of database,
  default is `mysql`. Other database types are not supported at this
  time.
* `node['confluence']['database_host']` - The database server host, by
  default `localhost`.
* `node['confluence']['database_user']` - The database user, by
  default `confluence`.
* `node['confluence']['database_name']` - The name of the database to
  use, by default `confluence`. Set this to a version specific value
  to be able to do upgrades with an easier backout plan.
* `node['confluence']['database_password']` - The database user's
  password. By default this is a randomly generated string from the
  `openssl` cookbook's `secure_password` library. When using
  chef-solo, this attribute must be specified. As it is set using
  `set_unless`, it is easy to override elsewhere if required.

### Other Cookbook Attributes

The Java cookbook sets the default install flavor to OpenJDK, but
OpenJDK is not supported by Confluence. We need to override this to
install Oracle's JDK by default. Note that we cannot set the
`node['java']['oracle']['accept_oracle_download_terms']` to true, so
you must set that attribute elsewhere, e.g. in a role.

* `node['java']['install_flavor']` - Use the specified flavor as the
  recipe name from the `java` cookbook.

# Recipes

The recipes are modular, so that only the required components for your
environment are managed if you don't want to use the opinionated
defaults.

## default

Use this for a default, opinionated setup of Confluence. This will
include the other recipes in the order described below. Two attributes
controll what database type and init style for the service, though at
this time only `mysql` and `runit`, respectively, are supported.

## create_user

Creates a system user to run confluence.

## install

This recipe includes `java::oracle` to get Java installed. As of this
cookbook version, Confluence
[does not support OpenJDK](http://jira.atlassian.com/browse/CONF-16431)
as the Java platform.

Several dependencies for Confluence plugins are installed as packages,
which is set from a platform-specific attribute,
`node['confluence']['plugin_dependencies']`.

Confluence itself is installed with the
[`ark` LWRP](http://ckbk.it/ark), and it will come from the URL
constructed by the version attribute. For example if the version
attribute is `4.3.7`:

- http://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-4.3.7.tar.gz

The installation will be in `/srv/confluence/confluence-VER` by
default, set by attributes (see above). The "`confluence.home`"
directory is `/srv/confluence/data-VER`, so that version specific home
directories can be maintained for upgrade purposes. Symbolic links are
created to `/srv/confluence/current` and `/srv/confluence/data`
respectively for the "current" version.

The installation notifies a recursive `chown` for
`node['confluence']['run_user']`.

## config

This recipe manages the following startup script helpers and
application configuration:

* bin/startup.sh
* bin/setenv.sh
* conf/server.xml
* confluence/WEB-INF/classes/confluence-init.properties

Each of these sends a delayed notification to a `service[confluence]`
resource. The `runit_service` recipe will create this resource. If
you're not using `runit` for managing your Confluence service, ensure
that you have a recipe that defines a `service[confluence]` resource.

## mysql

This recipe ensures that MySQL is installed (`recipe[mysql::server]`),
and that Ruby bindings are available (`recipe[mysql::ruby]`). It then
creates the database for Confluence as defined by the
`node['confluence']['database_name']` attribute, and manages
permissions for the user defined by the
`node['confluence']['database_user']` attribute.

## runit_service

This recipe ensures that runit is installed (`recipe[runit]`), creates
the log directory (`/var/log/confluence`), and sets up Confluence as a
service supervised by runit.

# Usage

Include `recipe[confluence]` in a node's run list and modify the
attributes as required for your infrastructure.

# Testing

See TESTING.md for information about running tests for this cookbook.

# License and Author

- Author:: Bryan McLellan <btm@loftninjas.org>
- Author:: Joshua Timberman <joshua@opscode.com>
- Copyright:: Copyright (c) 2011, Bryan McLellan
- Copyright:: Copyright (c) 2013, Opscode, Inc.
- License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
