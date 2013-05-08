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
 file {'/etc/mongodb.conf':
   ensure  => present,
   content => template('mongodconf.erb'),
   mode    => 644,
 }

}
