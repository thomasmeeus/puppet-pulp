class pulp::differentlocation {
file { '/data/mongodb':
  ensure => directory,
  owner  => 'mongodb',
  group  => 'root',
  mode   => 755,
 }
 file {'/var/lib/mongodb':
   ensure => 'link',
   force  => true,
   target => '/data/mongodb',
 }
  user {'mongodb':
    ensure => 'present',
  }
}
