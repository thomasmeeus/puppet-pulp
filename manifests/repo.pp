#Class pup::repo
#
class pulp::repo(
  $repo_enabled = true
){
  if $repo_enabled == true {
    yumrepo {'rhel-pulp':
      name     => 'Pulp v2 Production Releases',
      descr    => 'Pulp v2 Production Releases',
      baseurl  => 'http://repos.fedorapeople.org/repos/pulp/pulp/v2/stable/$releasever/$basearch/',
      enabled  => '1',
      gpgcheck => '0',
    }
  }
}

