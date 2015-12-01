# Puppet module: etcprofile

This is a Puppet module for to manage /etc/profile and /etc/profile.d
It provides only package installation and file configuration.

Based on Example42 layouts by Alessandro Franceschi / Lab42

Official site: http://www.example42.com

Official git repository: http://github.com/example42/puppet-etcprofile

Released under the terms of Apache 2 License.

This module requires the presence of Example42 Puppi module in your modulepath.


## USAGE - Basic management

* Enable auditing without making changes on existing profile configuration files

        class { 'etcprofile':
          audit_only => true
        }

* Use custom sources for /etc/profile

        class { 'etcprofile':
          source => [ "puppet:///modules/example42/etcprofile/profile.conf-${hostname}" , "puppet:///modules/example42/etcprofile/profile.conf" ], 
        }

* Place a custom script (using source) in /etc/profile.d/
  This creates the (executable) file: /etc/profile.d/java.sh

        etcprofile::script { 'java':
          source => 'puppet:///modules/example42/etcprofile/java.sh',
        }

* Place a custom script (using content) in /etc/profile.d/

        etcprofile::script { 'java':
          content => template('/example42/etcprofile/java.sh'),
        }

* Use custom source directory for the whole /etc/profile.d dir

        class { 'etcprofile':
          source_dir       => 'puppet:///modules/example42/etcprofile/conf/',
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for /etc/profile. Note that template and source arguments are mutually exclusive.

        class { 'etcprofile':
          template => 'example42/etcprofile/profile.conf.erb',
        }

* Automatically include a custom subclass

        class { 'etcprofile':
          my_class => 'example42::my_profile',
        }

* Remove profile resources (DO NOT DO THAT)

        class { 'etcprofile':
          absent => true
        }

[![Build Status](https://travis-ci.org/example42/puppet-profile.png?branch=master)](https://travis-ci.org/example42/puppet-profile)

