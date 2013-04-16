require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

Puppet::Type.type(:pulp).provide(:repository) do

  def exists?
  false
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
    req.basic_auth :user :password
    req.body = "#{:vars}"
    sock Net::HTTP.new(url.host, url.port)
    sock.use_ssl = true
    sock.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = sock.start {|http| http.request(req)}
    return res
  end
  
  def buildurl (pathvar)
    url = URI::HTTP.build({:host =>  hostname, :path => varpath})
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
    sendHash["id"] = :repoid
    sendHash["display_name"] = :displayname if :displayname
    sendHash["description"] = :description if :description
    sendHash["notes"] = Hash.new
    sendHash["notes"]["_repo-type"] = :repotype
    #TODO add extra note fields
    sendHash.to_json
    pathvar = '/pulp/api/v2/repositories/'

    res = postquery(pathvar, sendHash)

    #fail "Couldn't create repo: #{res.code} #{res.body}" unless res.kind_of? Net::HTTPSuccess
    if res.code == 200
      #output: the repository was successfully created
      Puppet.debug("Repository created")
    elsif res.code == 400
      #output: if one or more of the parameters is invalid
      fail("One or more of the parameters is invalid")
    elsif res.code == 409
      #output:  if there is already a repository with the given ID
      fail("There is already a repository with the given ID")
    else 
      fail("An unexpected error occurred")
    end

  end

  def update
    pathvar = '/pulp/api/v2/repositories/' + :repoid '/'
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
    pathvar = '/pulp/api/v2/repositories/' + :repoid '/'
    res = deletequery(pathvar)
    if res.code ==202
      Puppet.debug("The update is executed and succesfull"
    end
  end
  
end

