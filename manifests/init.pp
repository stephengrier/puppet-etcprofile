# Class: etcprofile
#
# Manages /etc/profile and /etc/profile.d/ directory
# == Parameters
#
# Standard class parameters
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, etcprofile class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $etcprofile_myclass
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, profile main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $etcprofile_source
#
# [*source_dir*]
#   If defined, the whole /etc/profile.d directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $etcprofile_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $etcprofile_source_dir_purge
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, profile main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $etcprofile_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $etcprofile_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $etcprofile_absent
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $etcprofile_audit_only
#   and $audit_only
#
# Default class params - As defined in etcprofile::params.
#
# [*config_dir*]
#   Main configuration directory.
#
# [*config_file*]
#   Main configuration file path
#
class etcprofile (
  $my_class            = params_lookup( 'my_class' ),
  $source              = params_lookup( 'source' ),
  $source_dir          = params_lookup( 'source_dir' ),
  $source_dir_purge    = params_lookup( 'source_dir_purge' ),
  $template            = params_lookup( 'template' ),
  $options             = params_lookup( 'options' ),
  $version             = params_lookup( 'version' ),
  $absent              = params_lookup( 'absent' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' ),
  $config_dir          = params_lookup( 'config_dir' ),
  $config_file         = params_lookup( 'config_file' )
  ) inherits ::etcprofile::params {

  ### Internal variables setting
  # Configurations directly retrieved from etcprofile::params
  $config_file_mode=$etcprofile::params::config_file_mode
  $config_file_owner=$etcprofile::params::config_file_owner
  $config_file_group=$etcprofile::params::config_file_group

  # Sanitize of booleans
  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_absent=any2bool($absent)
  $bool_audit_only=any2bool($audit_only)

  # Logic management according to parameters provided by users
  $manage_file = $etcprofile::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }
  $manage_audit = $etcprofile::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }
  $manage_file_replace = $etcprofile::bool_audit_only ? {
    true  => false,
    false => true,
  }
  $manage_file_source = $etcprofile::source ? {
    ''        => undef,
    default   => $etcprofile::source,
  }
  $manage_file_content = $etcprofile::template ? {
    ''        => undef,
    default   => template($etcprofile::template),
  }

  ### Resources managed by the module
  file { 'profile.conf':
    ensure  => $etcprofile::manage_file,
    path    => $etcprofile::config_file,
    mode    => $etcprofile::config_file_mode,
    owner   => $etcprofile::config_file_owner,
    group   => $etcprofile::config_file_group,
    source  => $etcprofile::manage_file_source,
    content => $etcprofile::manage_file_content,
    replace => $etcprofile::manage_file_replace,
    audit   => $etcprofile::manage_audit,
  }

  # The whole profile configuration directory is managed only
  # if $etcprofile::source_dir is provided
  if $etcprofile::source_dir and $etcprofile::config_dir != '' {
    file { 'profile.dir':
      ensure  => directory,
      path    => $etcprofile::config_dir,
      source  => $etcprofile::source_dir,
      recurse => true,
      purge   => $etcprofile::bool_source_dir_purge,
      replace => $etcprofile::manage_file_replace,
      audit   => $etcprofile::manage_audit,
    }
  }


  ### Include custom class if $my_class is set
  if $etcprofile::my_class {
    include $etcprofile::my_class
  }

}
