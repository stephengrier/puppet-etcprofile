# Define etcprofile::script
#
# This define creates a single script in /etc/profile.d
#
define etcprofile::script (
  $priority = '',
  $autoexec = false,
  $source   = '',
  $content  = '',
  $owner    = 'root',
  $group    = 'root',
  $mode     = '0755' ) {

  include etcprofile
  require etcprofile::params


  $safe_name = regsubst($name, '/', '_', 'G')
  $bool_autoexec = any2bool($autoexec)
  $manage_file_source = $source ? {
    ''        => undef,
    default   => $source,
  }
  $manage_file_content = $content ? {
    ''        => undef,
    default   => $content,
  }

  file { "etcprofile_${priority}_${safe_name}":
    path    => "${etcprofile::config_dir}/${priority}-${safe_name}.sh",
    mode    => $mode,
    owner   => $owner,
    group   => $group,
    content => $manage_file_content,
    source  => $manage_file_source,
    audit   => $etcprofile::manage_audit,
  }

  if $bool_autoexec == true {
    exec { "etcprofile_${priority}_${safe_name}":
      command     => "sh ${etcprofile::config_dir}/${priority}-${safe_name}.sh",
      refreshonly => true,
      subscribe   => File[ "etcprofile_${priority}_${safe_name}" ],
      path        => '/usr/bin:/bin:/usr/sbin:/sbin',
    }
  }
}

