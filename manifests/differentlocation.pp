# Class pulp::differentlocation
class pulp::differentlocation {
  file { '/data/mongodb':
    ensure => directory,
    owner  => 'mongodb',
    group  => 'root',
    mode   => '0755',
  }
  file {'/var/lib/mongodb':
    ensure => 'link',
    force  => true,
    target => '/data/mongodb',
  }
  file { '/data/pulp':
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    mode   => '0755',
  }
  file {'/var/lib/pulp':
    ensure => 'link',
    force  => true,
    target => '/data/pulp',
  }
  user {'mongodb':
    ensure => 'present',
  }
}
