# Class pulp::admin
class pulp::admin
$pulp_server_host = Facter.value('fqdn')
$pulp_server_port = '443'
){
  $packagelist = ['pulp-admin-client', 'pulp-puppet-admin-extensions', 'pulp-rpm-admin-extensions']
  package { $packagelist:
    ensure => 'installed',
  }
  file { '/etc/pulp/admin/admin.conf':
    ensure  => 'file',
    content => template('pulp/admin.conf.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package[$packgelist],
  }
}
