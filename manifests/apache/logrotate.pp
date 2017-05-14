## Class: profile::apache::logrotate
# A Class to manage the apache logrotate
#Dependencies:
# puppet module install yo61-logrotate

class profile::apache::logrotate {

    include ::logrotate

    logrotate::rule { 'httpd':
        ensure        => 'present',
        create        => true,
        create_mode   => 644,
        create_owner  => 'apache',
        create_group  => 'apache',
        su            => true,
        su_owner      => 'apache',
        su_group      => 'apache',
        delaycompress => true,
        ifempty       => true,
        missingok     => true,
        compress      => true,
        sharedscripts => true,
        path          => '/var/www/vhosts/*/logs/*.log /var/log/httpd/*log',
        rotate        => 30,
        rotate_every  => 'daily',
        postrotate    => 'if [ -f /var/run/httpd/httpd.pid -o -f /var/run/httpd.pid ];then /sbin/service httpd reload > /dev/null 2>/dev/null || true;fi'
    }
}
