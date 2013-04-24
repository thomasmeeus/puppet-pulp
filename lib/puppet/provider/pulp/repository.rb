require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

Puppet::Type.type(:pulp).provide(:repository) do

  def exists?
    res = getrepo(resource[:repoid])
    if res.code.to_i == 200
    #puts res.body
      completehash =JSON.parse(res.body)
      noteshash = JSON.parse(completehash.fetch("notes").to_json)

      importershash = JSON.parse(completehash.fetch("importers").to_json[1..-2]) #werkt
      importersconfig = JSON.parse(importershash.fetch("config").to_json) #werkt 
      
      distributorshash = JSON.parse(completehash.fetch("distributors").to_json[1..-2]) #werkt
      distributorsconfig = JSON.parse(distributorshash.fetch("config").to_json) #werkt 
      
      conditions = Hash.new
      conditions["id"] = resource[:repoid]
      conditions["description"] = resource[:description]
      conditions["display_name"] = resource[:displayname]
      
      conditionsnotes = Hash.new
      conditionsnotes["_repo-type"] = resource[:repotype]

      importers = Hash.new
      importers["id"] = "yum_importer"

      importersconfighash = Hash.new
      importersconfighash["feed_url"] = resource[:feed]
      importersconfighash["ssl_ca_cert"] = resource[:feedcacert] if resource[:feedcacert]
      importersconfighash["ssl_client_cert"] = resource[:feedcert] if resource[:feedcert]
      importersconfighash["ssl_client_key"] = resource[:feedkey] if resource[:feedkey]
      returnvalue = true
      
      test = JSON.parse(createrepohash())
      test.each{ |key, value|
        if value.class == Hash
          value.each{ |key, value|
            if value.class == Array
              tester = Hash[*value]
              tester.each{ |key, value|
                puts key
                puts value
                puts ""
              }
            elsif value.class == Hash
              tester.each{ |key, value|
                puts key
                puts value
                puts ""
              }
      
            else
              puts key
              puts value
              puts value.class
              puts ""
            end
          }
          elsif value.class == Array
            puts "############################"
            puts "#######"+ key + "############"
            tester = Hash[*value]
            tester.each{ |key, value|
              puts key
              puts value
              puts ""
            }
            puts "############################"
        else
          puts key
          puts value
          puts value.class
          puts ""
        end
        }

      return true

    elsif res.code.to_i == 404
      puts "bestaat nog ni"
      return false
    end

  end
  
  def getrepo(id)
    pathvar = "/pulp/api/v2/repositories/" + id + "/"
    sendVar = creategetrepoinfohash()
    url = URI::HTTPS.build({:host =>  resource[:hostname] , :path => pathvar, :query => 'details=True'})
    res = getquery(pathvar, sendVar)
    return res
  end

  def query (req, url, vars)
    req.basic_auth resource[:user], resource[:password]
    req.body = "#{vars}"
    sock = Net::HTTP.new(url.host, url.port)
    sock.use_ssl = true
    sock.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = sock.start{|http| http.request(req)}
    return res
  end
  
  def buildurl (pathvar)
    url = URI::HTTPS.build({:host =>  resource[:hostname] , :path => pathvar})
    return url
  end

  def postquery (pathvar, vars)
    url = buildurl(pathvar)
    req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def putquery (pathvar, vars)
    url = buildurl(pathvar)
    req = Net::HTTP::Put.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def getquery (pathvar, vars)
    #url = buildurl(pathvar) 
    url = URI::HTTPS.build({:host =>  resource[:hostname] , :path => pathvar, :query => 'details=True'})
    req = Net::HTTP::Get.new(url.request_uri)
    #req = Net::HTTP::Get.new(url.path, url.query, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def deletequery (pathvar)
    url = buildurl(pathvar)
    req = Net::HTTP::Delete.new(url.path, initheader = {'Content-Type' =>'application/json'})
    vars = nil
    res = query(req, url, vars)
    return res
  end
  
  def createrepohash
    sendHash = Hash.new
    sendHash["id"] = resource[:repoid]
    sendHash["display_name"] = resource[:displayname] if resource[:displayname]
    sendHash["description"] = resource[:description] if resource[:description]
    sendHash["notes"] = Hash.new
    sendHash["notes"]["_repo-type"] = resource[:repotype]
    #TODO add extra note fields
    sendVar = sendHash.to_json
    return sendVar
  end

  def createimporterhash
    sendHash = Hash.new
    sendHash["importer_type_id"] = "yum_importer"
    sendHash["importer_config"] = Hash.new
    sendHash["importer_config"]["feed_url"] = resource[:feed]
    sendHash["importer_config"]["ssl_ca_cert"] = resource[:feedcacert] if resource[:feedcacert]
    sendHash["importer_config"]["ssl_client_cert"] = resource[:feedcert] if resource[:feedcert]
    sendHash["importer_config"]["ssl_client_key"] = resource[:feedkey] if resource[:feedkey]

    sendVar = sendHash.to_json
    return sendVar
  end
  
  def creategetrepoinfohash
    sendHash = Hash.new
    sendHash["details"] = 'True'
    sendVar = sendHash.to_json
    return sendVar
  end

  def createdistributorhash(id)
    sendHash = Hash.new
    sendHash["distributor_id"] = id
    sendHash["distributor_type_id"] = id
    sendHash["distributor_config"] = Hash.new
    #sendHash["distributor_config"]["http"] = true
    sendHash["distributor_config"]["http"] = (resource[:servehttp]!=:false)
    sendHash["distributor_config"]["https"] = (resource[:servehttps]!=:false)
    sendHash["distributor_config"]["auth_ca"] = resource[:authca] if resource[:authca]
    sendHash["distributor_config"]["https_ca"] = resource[:httpsca] if resource[:httpsca]
    sendHash["distributor_config"]["gpgkey"] = resource[:gpgkey] if resource[:gpgkey]
    sendHash["distributor_config"]["relative_url"] = resource[:repoid] #probably bug in pulp, doc says it's an optional parameter bug errors when you don't provide it. 

    sendVar = sendHash.to_json
    return sendVar
  end

  def createimporter
    sendVar = createimporterhash()
    pathvar = '/pulp/api/v2/repositories/' + resource[:repoid] + '/importers/'
    res = postquery(pathvar, sendVar)

    if res.code.to_i == 201
      #output: the repository was successfully created
      Puppet.debug("The importer was created succesfully")
    elsif res.code.to_i == 400
      #output: if one or more of the parameters is invalid
      fail("one or more of the required parameters is missing, the importer type ID refers to a non-existent importer, or the importer indicates the supplied configuration is invalid")
    elsif res.code.to_i == 404
      #output:  if there is already a repository with the given ID
      fail("there is no repository with the given ID")
    elsif res.code.to_i == 500
      fail("the importer raises an error during initialization")
    else 
      fail("An unexpected test error occurred" + res.code )
    end

  end

  def createdistributor(id)
    sendVar = createdistributorhash(id)
    pathvar = '/pulp/api/v2/repositories/' + resource[:repoid] + '/distributors/'
    res = postquery(pathvar, sendVar)
    if res.code.to_i == 201
      #output: the repository was successfully created
      Puppet.debug("The distributor was created succesfully")
    elsif res.code.to_i == 400
      #output: if one or more of the parameters is invalid
      fail("one or more of the required parameters is missing, the distributor type ID refers to a non-existent distributor, or the distributor indicates the supplied configuration is invalid" + res.body)
    elsif res.code.to_i == 404
      #output:  if there is already a repository with the given ID
      fail("there is no repository with the given ID" + res.code)
    elsif res.code.to_i == 500
      fail("the distributor raises an error during initialization")
    else 
      fail("An unexpected test error occurred" + res.code )
    end

  end
  
  def createrepo
    sendVar = createrepohash()
    pathvar = '/pulp/api/v2/repositories/'

    res = postquery(pathvar, sendVar)
    
    if res.code.to_i == 201
      #output: the repository was successfully created
      Puppet.debug("Repository created")
    elsif res.code.to_i == 400
      #output: if one or more of the parameters is invalid
      fail("One or more of the parameters is invalid")
    elsif res.code.to_i == 409
      #output:  if there is already a repository with the given ID
      fail("There is already a repository with the given ID")
    else 
      fail("An unexpected test error occurred" + res.code )
    end

  end

  def create
    Puppet.debug("start creating repo")
    createrepo()
    Puppet.debug("repo created")
    createimporter()
    # createdistributor("export_distributor")
    createdistributor("yum_distributor")
    res = getrepo(resource[:repoid])
    #puts res.body #TODO remove
   
  end

  def update
    pathvar = '/pulp/api/v2/repositories/' + resource[:repoid] +  '/'
    res = putquery(pathvar, sendHash)

    if res.code.to_i == 200
      Puppet.debug("The update is executed and succesfull")
    elsif res.code.to_i == 202
      fail("The update was postponed")
    elsif res.code.to_i == 400
      fail("One or more of the parameters is invalid")
    elsif res.code.to_i == 400
      fail("One or more of the parameters is invalid")
    else 
      fail("An unexpected error occurred")
    end

  
  end

  def destroy
    pathvar = '/pulp/api/v2/repositories/' + resource[:repoid] + '/'
    res = deletequery(pathvar)
    if res.code.to_i ==202
      Puppet.debug("The update is executed and succesfull")
    else 
      fail("An unexpected error occured")
    end
    if resource[:removeorphans] == true
      pathvarorphans = '/pulp/api/v2/content/orphans/'
      resorphans = deletequery(pathvarorphans)
      if resorphans.code.to_i ==202
        Puppet.debug("All orphans are removed")
      else
        fail("An unexpected error occured")
      end
    end
  end
  
end

