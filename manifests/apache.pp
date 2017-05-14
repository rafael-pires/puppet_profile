#
class profile::apache() {
  $webroot    = '/var/www/vhosts/'
  $vhost_prefix = hiera('profile::apache::vhost_prefix', "${environment}-")

  group { 'apache':
    gid     => 48,
  } ->

  user { 'apache':
    comment => 'Apache',
    uid     => 48,
    gid     => 48,
    home    => '/var/www',
    shell   => '/sbin/nologin',
  } ->

  class { '::apache':
    default_type           => 'text/plain',
    default_charset        => 'UTF-8',
    default_vhost          => false,
    default_mods           => false,
    keepalive              => 'On',
    keepalive_timeout      => 2,
    log_formats            => {
                                'combined' => '%h %{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D'
                              },
    manage_user            => false,
    manage_group           => false,
    max_keepalive_requests => 100,
    mpm_module             => false,
    server_tokens          => 'Prod',
    server_signature       => 'Off',
    trace_enable           => 'Off',
    vhost_dir              => '/etc/httpd/sites-available',
    vhost_enable_dir       => '/etc/httpd/sites-enabled',
  }

  class {'::apache::mod::status':
    allow_from => [ '127.0.0.1', $::ipaddress_eth0 ]
  }

  Apache::Vhost{
    port            =>  80,
    access_log_file => 'access.log',
    error_log_file  => 'error.log',
    log_level       => 'warn'
  }

  apache::vhost {
    "${::fqdn}-localstatus":
      add_listen => false,
      ip         => '127.0.0.1',
      ip_based   => true,
      priority   => false,
      servername => 'localhost',
      docroot    => "${webroot}/${::fqdn}-localstatus/htdocs",
      logroot    => "${webroot}/${::fqdn}-localstatus/logs", ;
    "${::fqdn}-remotestatus":
      priority   => false,
      servername => $::fqdn,
      docroot    => "${webroot}/${::fqdn}-remotestatus/htdocs",
      logroot    => "${webroot}/${::fqdn}-remotestatus/logs", ;
  }

  file {
    [ $webroot,
    "${webroot}/${::fqdn}-localstatus",
    "${webroot}/${::fqdn}-remotestatus" ]:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package[$::apache::apache_name];
    [ "${webroot}/${::fqdn}-localstatus/htdocs",
    "${webroot}/${::fqdn}-localstatus/logs",
    "${webroot}/${::fqdn}-remotestatus/htdocs",
    "${webroot}/${::fqdn}-remotestatus/logs", ]:
      ensure => 'directory',
      owner  => 'apache',
      group  => 'apache',
      mode   => '0755', ;
  }
}