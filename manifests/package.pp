# = Class: pulp::package
class pulp::package {
  package {
    'pulp':
      ensure => 'present';
    'pulp-admin':
      ensure => 'present';
  }

  file {
    '/var/lib/pulp/init.flag':
      require => Exec['pulpinit']
  }

  exec { 'pulpinit':
    command => '/etc/init.d/pulp-server init && touch /var/lib/pulp/init.flag',
    creates => '/var/lib/pulp/init.flag',
    require => Package['pulp'],
  }
}
