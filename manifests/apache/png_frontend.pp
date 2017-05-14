#
class profile::apache::png_frontend() inherits ::profile::apache {

  $vhosts = {
    'common-lcm.xxx.com' => {
      rewrites => [
        {
          comment       => 'Preventing TRACK/TRACE calls to apache.',
          rewrite_cond  => '%{REQUEST_METHOD} ^(TRACE|TRACK)',
          rewrite_rule  => '.* - [F]  Microsoft Internet Information Services (IIS)',
        },
      ],
    },
    'ex-lcm.xxx.com' => {
      rewrites => [
        {
          comment       => '',
          rewrite_cond  => '%{REQUEST_FILENAME} !-f',
          rewrite_rule  => '^(.*)$ /index.php/$1 [L]',
        }
      ],
      custom_fragment => [
        'Options +FollowSymLinks'
      ],
    },
  }

  $vhost_subdirs = [
    'private',
    'logs',
    'logs/application',
    'logs/application/assets',
    'logs/application/framework',
    'logs/application/logs/',
    'logs/application/runtime',
    'logs/application/runtime/view',
    'logs/application/runtime/cache',
    'logs/application/runtime/session',
  ] # pls dont add htdocs or conf

  class { '::apache::mod::prefork':
    startservers        => '8',
    minspareservers     => '8',
    maxspareservers     => '16',
    serverlimit         => '400',
    maxclients          => '400',
    maxrequestsperchild => '0',
  }

  $std_frag = "AddType text/cache-manifest .appcache\n  AddType image/svg+xml svg"

  class { '::apache::mod::mime':        }
  class { '::apache::mod::setenvif':    }
  class { '::apache::mod::alias':       }
  class { '::apache::mod::autoindex':   }
  class { '::apache::mod::rewrite':     }
  class { '::apache::mod::headers':     }
  class { '::apache::mod::negotiation': }
  class { '::apache::mod::deflate':     }
  class { '::apache::mod::dir':         }
  class { '::apache::mod::expires':     }
  class { '::apache::mod::proxy':       }
  class { '::apache::mod::proxy_http':  }
  class { '::apache::mod::proxy_balancer': }
  class { '::apache::mod::php':
    package_name => 'xxx-php' }
  apache::mod { 'env': }

  File {
    owner   => 'apache',
    group   => 'apache',
    mode    =>  '775',
    ensure  => 'directory',
  }

  $vhosts.keys.each |$vhost| {
    $http_vhost = "${profile::apache::vhost_prefix}${vhost}"
    $vhost_subdirs_path = prefix($vhost_subdirs, "${::profile::apache::webroot}${http_vhost}/")
    file {
      "${::profile::apache::webroot}${http_vhost}":
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',;
      "${::profile::apache::webroot}${http_vhost}/htdocs":
        mode    => '2775';
      $vhost_subdirs_path : ;
    }
    if has_key($vhosts[$vhost], custom_fragment) {
      $customfrag = join($vhosts[$vhost][custom_fragment], "\n  ")
    }
    apache::vhost { "80_${http_vhost}":
      servername      => $http_vhost,
      port            => 80,
      ssl             => false,
      log_level       => 'warn',
      manage_docroot  => false,
      docroot         => "${::profile::apache::webroot}${http_vhost}/htdocs",
      logroot         => "${::profile::apache::webroot}${http_vhost}/logs",
      custom_fragment => "${std_frag}\n  ${customfrag}",
      rewrites        => $vhosts[$vhost][rewrites],
      directories     => $vhosts[$vhost][directories],
    }
  }
}
