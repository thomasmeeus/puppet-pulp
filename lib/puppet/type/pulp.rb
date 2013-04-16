Puppet::Type.newtype(:pulp)do
  @doc = "Interface to manage pulp from within puppet"
  
  feature :createable, "The provider can create a repository",
    :methods => [:create]
  feature :updateble, "The provider can update the settings of a repository",
    :methods => [:update]
  feature :syncable, "The provider can synchronize a repository"
    :methods => [:sync]
  
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
    defaultto('rpm_repo')
  end

  newparam(:feed) do 
    desc "full path to the feed that acts as source "
    validate do \value\
      unless Pathname.new(value).absolute? ||
        URI.parse(value).is_a?(URI::HTTP)
        fail("Invalid source #{value}")
      end
    end
  end

  newparam(:feedcacert) do
    desc "full path to the certificate CA to use for authentication"
  end

  newparam(:user) do
    desc "Specify which user executes the commands"
    defaultto("admin")
  end

  newparam(:password) do
    desc "Specify the password of the user"
  end

  newparam(:feedcert) do
    desc "full path to the certificate to use for authentication when accessing the external feed"
  end

  newparam(:feedkey) do
    desc "full path to the private key for feed_cert"
  end

  newparam(:hostname) do
    desc "hostname of the pulp-server"
    defaultto :fqdn
end
