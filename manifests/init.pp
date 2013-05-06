# Class: pulp
#
# This module manages pulp and also allows you to define repositories to sync.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class pulp (
  $pulp_version = '2',
  $pulp_server = true,
  $pulp_client = false,
  $pulp_admin = true,
  $pulp_server_host = Facter.value('fqdn')


){
}
