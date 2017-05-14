#= Class profile::memcached
# Purpose: 
# - Creates memcached user/group with standard ids
# - installs memcached packages
# - configures memcached
# - Manages memcached service
# - Manages memcache log rotation
# Dependencies
# puppet module install saz-memcached --version 3.0.1
# puppet module install yo61-logrotate
class profile::memcached {
  include ::logrotate

  group { 'memcached':
    ensure => 'present',
    gid    => '499',
  } ->

  user { 'memcached':
    ensure           => 'present',
    comment          => 'Memcached daemon',
    gid              => '499',
    home             => '/var/run/memcached',
    password_max_age => '-1',
    password_min_age => '-1',
    shell            => '/sbin/nologin',
    uid              => '498',
  } ->

  class { '::memcached' :
    max_memory      => '25%',
    logfile         => '/var/log/memcached',
    max_connections => 4096,
    verbosity       => 'vv',
    processorcount  => 8,
    listen_ip       => '0.0.0.0',
  }

  logrotate::rule { 'memcached':
    ensure        => 'present',
    create        => true,
    create_mode   => 644,
    delaycompress => true,
    ifempty       => true,
    missingok     => true,
    compress      => true,
    path          => '/var/log/memcached',
    rotate        => 10,
    rotate_every  => 'daily',
    copytruncate  => true,
  }
}