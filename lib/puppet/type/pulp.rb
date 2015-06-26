require 'facter'
Puppet::Type.newtype(:pulp) do
  @doc = "Interface to manage pulp from within puppet"
#  feature :createable, "The provider can create a repository",
#    :methods => [:create]
#  feature :updateble, "The provider can update the settings of a repository",
#    :methods => [:update]
#  feature :syncable, "The provider can synchronize a repository"
#    :methods => [:sync]

  ensurable
  newparam(:repoid, :namevar => true) do
    desc "Repository id"
  end

  newparam(:displayname) do
    desc "Repository display name"
  end

  newparam(:description) do
    desc "Repository description"
  end

  newparam(:onlynewest) do
    desc "Only newest version op a given package is downloaded"
    newvalues(:true, :false)
  end

  newparam(:repotype) do
    desc "Descripes witch type of repository you want to create"
    defaultto('rpm-repo')
  end

  newparam(:feed) do
    desc "full path to the feed that acts as source "
    validate do |value|
      unless Pathname.new(value).absolute? ||
        URI.parse(value).is_a?(URI::HTTP)
        fail("Invalid source #{value}")
      end
    end
  end

  newparam(:user) do
    desc "Specify which user executes the commands"
    defaultto("admin")
  end

  newparam(:password) do
    desc "Specify the password of the user"
    defaultto("admin")
  end

  newparam(:hostname) do
    desc "hostname of the pulp-server"
    defaultto Facter.value('fqdn')
  end
  
  newparam(:removeorphans) do
    desc "removes all orphan packages"
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:servehttp) do
    desc "Flag indicating if the repository will be served over a non-SSL connection. Valid values to this option are True and False. This option is required."
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:servehttps) do
    desc "Flag indicating if the repository will be served over an SSL connection. If this is set to true, the https_ca option should also be specified to ensure consumers bound to this repository have the necessary certificate to validate the SSL connection. Valid values to this option are True and False. This option is required."
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:gpgkey) do
    desc "GPG key used to sign RPMs in this repository. This key will be made available to consumers to use in verifying content in the repository. The value to this option must be the full path to the GPG key file."
  end

  newparam(:httpsca) do
    desc "CA certificate used to sign the SSL certificate the server is using to host this repository. This certificate will be made available to bound consumers so they can verify the server’s identity. The value to this option must be the full path to the certificate."
  end

  newparam(:authca) do
    desc "CA certificate that was used to sign the certificate specified in auth-cert. The server will use this CA to verify that the incoming request’s client certificate is signed by the correct source and is not forged. The value to this option must be the full path to the CA certificate file."
  end

  newparam(:feedcacert) do
    desc "Full path to the CA certificate that should be used to verify the external repo server's SSL certificate"
  end

  newparam(:feedcert) do
    desc "Full path to the certificate to use for authentication when accessing the external feed"
  end

  newparam(:feedkey) do
    desc "Full path to the private key for feed_cert"
  end

  newparam(:relative_url) do
    desc "Relative URL for the repository."
  end

  newparam(:validate) do
    desc "The size and checksum of each synchronized file willbe verified against the repo metadata"
  end

  newparam(:remove_missing) do
    desc "Units that were previously in the external feed but are no longer found will be removed from the repository"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:retain_old_count) do
    desc "Number of non-latest versions of a unit to leave in a repository"
    defaultto(0)
  end

  newparam(:remove_old) do
    desc "Option to remove old packages"
    newvalues(:true, :false)
    defaultto(:false)
  end
end
