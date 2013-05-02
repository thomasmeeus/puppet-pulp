require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'


class Importer

  attr_accessor :id
  attr_accessor :feed_url
  attr_accessor :ssl_ca_cert
  attr_accessor :ssl_client_cert
  attr_accessor :ssl_client_key

  def initialize(importerhash, type)
  if type == "completehash"
    @hash = Hash[*importerhash["importers"]]
    @config = "config"
    @id = @hash["id"]
  else
    puts "tis een zelfgemaakte hash"
    @hash = importerhash
    @config = "importer_config"
    @id = @hash["importer_type_id"]
  end

  @feed_url = @hash[@config]["feed_url"] if @hash[@config]["feed_url"]
  @ssl_ca_cert = @hash[@config]["ssl_ca_cert"] if @hash[@config]["ssl_ca_cert"]
  @ssl_client_cert = @hash[@config]["ssl_client_cert"] if @hash[@config]["ssl_client_cert"]  
  @ssl_client_key = @hash[@config]["ssl_client_key"] if @hash[@config]["ssl_client_key"] 
  end
  
end

class Distributor
  attr_accessor :id
  attr_accessor :http
  attr_accessor :https
  attr_accessor :relative_url
  attr_accessor :gpgkey
  attr_accessor :auth_ca
  attr_accessor :https_ca
  attr_accessor :type_id
  attr_accessor :hash

  def initialize(distributorhash, type)
  if type == "completehash"
    @hash = Hash[*distributorhash["distributors"]]
    @id =  @hash["id"]
    @config = "config"
  else
    puts "tis een zelfgemaakte distributor hash"
    @hash = distributorhash
    @config = "distributor_config"
    @id =  @hash["distributor_id"]
  end

    @type_id =  @hash["distributor_type_id"]
    @http = @hash[@config]["http"]
    @https = @hash[@config]["https"]
    @auth_ca =  @hash[@config]["auth_ca"] if @hash[@config]["auth_ca"]
    @https_ca = @hash[@config]["https_ca"] if @hash[@config]["https_ca"]
    @gpgkey =  @hash[@config]["gpgkey"]  if @hash[@config]["gpgkey"]
    @relative_url =@hash[@config]["relative_url"]
  end

end

class Repository
  include Comparable
  attr_accessor :id
  attr_accessor :display_name
  attr_accessor :description
  attr_accessor :repo_type

  def initialize(repohash)
  @hash = repohash
  @id = @hash["id"] 
  @display_name = @hash["display_name"] if @hash["display_name"]
  @description = @hash["description"] if @hash["description"]
  @repo_type = @hash["notes"]["_repo-type"]
  end

  def ==(another_repository)
    self.id == another_repository.id
    self.display_name == another_repository.display_name
    self.description == another_repository.description
    puts self.description 
    puts another_repository.description
    #self.repo_type == another_repository.repo_type

  end
end

Puppet::Type.type(:pulp).provide(:repository) do

  def exists?
    res = getrepo(resource[:repoid])
    if res.code.to_i == 200
      #if the repository exist fetch the configuration
      completehash =JSON.parse(res.body)
      puts "bestaat al"

      actual_repository = Repository.new(completehash)
      manifest_repository = Repository.new(createrepohash())
      actual_importer = Importer.new(completehash, "completehash")
      manifest_importer = Importer.new(createimporterhash(), "ownhash")
      actual_distributor = Distributor.new(completehash, "completehash")
      manifest_distributor = Distributor.new(createdistributorhash("yum_distributor"), "ownhash")
      
      check_repo = Hash.new
      check_repo["id"] = comparevalue(actual_repository.id, manifest_repository.id)
      check_repo["display_name"] = comparevalue(actual_repository.display_name, manifest_repository.display_name)
      check_repo["description"] = comparevalue(actual_repository.description, manifest_repository.description)
      check_repo["repo_type"] = comparevalue(actual_repository.repo_type, manifest_repository.repo_type)
      checkrepo(check_repo)

      check_importer = Hash.new
      check_importer["id"] = comparevalue(actual_importer.id, manifest_importer.id)
      check_importer["feed_url"] = comparevalue(actual_importer.feed_url, manifest_importer.feed_url)
      check_importer["ssl_ca_cert"] = comparevalue(actual_importer.ssl_ca_cert, manifest_importer.ssl_ca_cert)
      check_importer["ssl_client_cert"] = comparevalue(actual_importer.ssl_client_cert, manifest_importer.ssl_client_cert)
      check_importer["ssl_client_key"] = comparevalue(actual_importer.ssl_client_key, manifest_importer.ssl_client_key)
      checkimporter(check_importer)

      check_distributor = Hash.new
      check_distributor["id"] = comparevalue(actual_distributor.id, manifest_distributor.id)
      check_distributor["http"] = comparevalue(actual_distributor.http, manifest_distributor.http)
      check_distributor["https"] = comparevalue(actual_distributor.https, manifest_distributor.https)
      check_distributor["relative_url"] = comparevalue(actual_distributor.relative_url, manifest_distributor.relative_url)
      check_distributor["gpgkey"] = comparevalue(actual_distributor.gpgkey, manifest_distributor.gpgkey)
      check_distributor["auth_ca"] = comparevalue(actual_distributor.auth_ca, manifest_distributor.auth_ca)
      check_distributor["https_ca"] = comparevalue(actual_distributor.https_ca, manifest_distributor.https_ca)
      check_distributor["type_id"] = comparevalue(actual_distributor.type_id, manifest_distributor.type_id)
      checkdistributor(check_distributor)
      return true

    elsif res.code.to_i == 404
      puts "bestaat nog ni"
      return false
    end

  end
  
  def checkdistributor(checkdistributorhash)
    checkdistributorhash.each{ |key, value|
      puts key
      puts value
      if value == false
        pathvar = '/pulp/api/v2/repositories/' + resource[:repoid] + '/distributors/' + resource[:repoid] + '/'
        res = deletequery(pathvar)
        puts res.code
        createdistributor("yum_distributor")
      end
    }
  end

  def checkimporter(checkimporterhash)
    checkimporterhash.each{ |key, value|
      if value == false
        createimporter()
      end
    }

  end

  def checkrepo(checkrepohash)
  
    checkrepohash.each { |key, value|
      if value == false
        update_hash = Hash.new
        update_hash["delta"] = createrepohash()
        update(update_hash.to_json)
      end
    }


  end

  def comparevalue(actualrepo, manifestrepo)
    if actualrepo == manifestrepo
      return true
    else 
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
    return sendHash
  end

  def createimporterhash
    sendHash = Hash.new
    sendHash["importer_type_id"] = "yum_importer"
    sendHash["importer_config"] = Hash.new
    sendHash["importer_config"]["feed_url"] = resource[:feed]
    sendHash["importer_config"]["ssl_ca_cert"] = resource[:feedcacert] if resource[:feedcacert]
    sendHash["importer_config"]["ssl_client_cert"] = resource[:feedcert] if resource[:feedcert]
    sendHash["importer_config"]["ssl_client_key"] = resource[:feedkey] if resource[:feedkey]
    #sendHash["importer_config"]["num_threads"] = 3
    #sendHash["importer_config"]["newest"] = false
    #TODO add all importer configuration parameters
    return sendHash
  end
  
  def creategetrepoinfohash
    sendHash = Hash.new
    sendHash["details"] = 'True'
    sendVar = sendHash.to_json
    return sendVar
  end

  def createdistributorhash(id)
    sendHash = Hash.new
    sendHash["distributor_id"] = resource[:repoid]
    sendHash["distributor_type_id"] = id
    sendHash["distributor_config"] = Hash.new
    sendHash["distributor_config"]["http"] = (resource[:servehttp]!=:false)
    sendHash["distributor_config"]["https"] = (resource[:servehttps]!=:false)
    sendHash["distributor_config"]["auth_ca"] = resource[:authca] if resource[:authca]
    sendHash["distributor_config"]["https_ca"] = resource[:httpsca] if resource[:httpsca]
    sendHash["distributor_config"]["gpgkey"] = resource[:gpgkey] if resource[:gpgkey]
    sendHash["distributor_config"]["relative_url"] = resource[:repoid]

    return sendHash
  end

  def createimporter
    sendVar = createimporterhash().to_json
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
  
  def deletedistributor(id)

  end

  def createdistributor(id)
    sendVar = createdistributorhash(id).to_json
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
    sendVar = createrepohash().to_json
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
   
  end

  def update(sendHash)
    pathvar = '/pulp/api/v2/repositories/' + resource[:repoid] +  '/'
    res = putquery(pathvar, sendHash)
    puts res.code
    if res.code.to_i == 200
      Puppet.debug("The update is executed and succesfull")
    elsif res.code.to_i == 202
      fail("The update was postponed")
    elsif res.code.to_i == 400
      fail("One or more of the parameters is invalid")
    elsif res.code.to_i == 400
      fail("One or more of the parameters is invalid")
    else 
      puts res
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

