# Class: pulp::server
class pulp::server (
  $mongodb_host = Facter.value('fqdn'),
  $mongodb_host = '27017',
  
