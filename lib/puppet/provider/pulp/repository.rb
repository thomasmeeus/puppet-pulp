require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

Puppet::Type.type(:pulp).provide(:repository) do

  def exists?
  Puppet.debug("check if exists")
  #  false
  #begin
      #code to check is the repo exists
      #pathvar = '/pulp/api/v2/repositories/' + :repoid + '/'
       

      #   jdoc = JSON.parse(res.body)
      #response = jdoc.fetch(:description)
      #rescue Puppet::ExecutionFailure => e
      # false
      #end
  end
  
  def query (req, url, vars)
    req.basic_auth resource[:user], resource[:password]
    req.body = "#{vars}"
    #url = URI.parse("https://pulpserver2.example.com/pulp/api/v2/repositories/")
    sock = Net::HTTP.new(url.host, url.port)
    sock.use_ssl = true
    sock.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = sock.start{|http| http.request(req)}
    return res
  end
  
  def buildurl (pathvar)
  
  #url = URI::HTTPS.build({:host =>  'www.test.com' , :path => pathvar})
  url = URI::HTTPS.build({:host =>  resource[:hostname] , :path => pathvar})
  puts url.to_s
    return url
  end

  def postquery (pathvar, vars)
    url = buildurl(pathvar)
    req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def putquery (url)
    url = buildurl(pathvar)
    req = Net::HTTP::Put.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def getquery (url)
    url = buildurl(pathvar)
    req = Net::HTTP::Get.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def deletequery (pathvar)
    url = buildurl(pathvar)
    req = Net::HTTP::Delete.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url)
    return res
  end

  def create

    sendHash = Hash.new
    sendHash["id"] = resource[:repoid]
    sendHash["display_name"] = resource[:displayname] if resource[:displayname]
    sendHash["description"] = resource[:description] if resource[:description]
    sendHash["notes"] = Hash.new
    sendHash["notes"]["_repo-type"] = resource[:repoid]
    #TODO add extra note fields
    sendVar = sendHash.to_json
    pathvar = '/pulp/api/v2/repositories/'

    res = postquery(pathvar, sendVar)

    if res.code.to_i == 201
      #output: the repository was successfully created
      puts resource[:hostname]
      Puppet.debug("Repository created")
    elsif res.code == 400
      #output: if one or more of the parameters is invalid
      fail("One or more of the parameters is invalid")
    elsif res.code.to_i == 409
      #output:  if there is already a repository with the given ID
      fail("There is already a repository with the given ID")
    else 
      fail("An unexpected test error occurred" + res.code )
    end

  end

  def update
    pathvar = '/pulp/api/v2/repositories/' + :repoid +  '/'
    res = putquery(pathvar, sendHash)

    if res.code == 200
      Puppet.debug("The update is executed and succesfull")
    elsif res.code == 202
      fail("The update was postponed")
    elsif res.code == 400
      fail("One or more of the parameters is invalid")
    elsif res.code == 400
      fail("One or more of the parameters is invalid")
    else 
      fail("An unexpected error occurred")
    end

  
  end

  def destroy
    #code to delete a repo
    pathvar = '/pulp/api/v2/repositories/' + :repoid + '/'
    res = deletequery(pathvar)
    if res.code ==202
      Puppet.debug("The update is executed and succesfull")
    end
  end
  
end

