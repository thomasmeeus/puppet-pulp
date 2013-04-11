Puppet::Type.newtype(:pulp)do
				@doc = "Interface to manage pulp from within puppet"

				feature :create_repository,
								"The provider" 

				newparam :repoid, :namevar => true do
								desc "Repository id"
				end

				newparam :displayname do
								desc "Repository display name"
				end

				newparam :description do
								desc "Repository description"
				end

				newparam :lastsync do
								desc "Last syncronisation date"
				end

				newparam :onlynewest do 
								desc "Only newest version op a given package is downloaded"
								newvalues(:true, :false)
				end

				newparam :feedcacert do 
								desc "full path to the CA certificate that should be used to verify the external repo server's SSL certificate"
				end

				newparam :feedcert do
								desc "full path to the certificate to use for authentication when accessing the external feed"
				end

				newparam :feedkey do
								desc "full path to the private key for feed_cert"
				end

end
