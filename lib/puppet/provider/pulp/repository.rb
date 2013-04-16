require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

Puppet::Type.type(:pulp).provide(:repository) do

  def exists?
    begin
      #code to check is the repo exists
      #@repoId = :repoid
      pathvar = '/pulp/api/v2/repositories/' + :repoid + '/'
      

      url = URI.parse("https://pulpserver2.example.com/pulp/api/v2/repositories/")
      jdoc = JSON.parse(res.body)
      response = jdoc.fetch(:description)
    rescue Puppet::ExecutionFailure => e
      false
    end
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
    req = Net::HTTP::Put.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res
  end

  def getquery (url)
    req = Net::HTTP::Get.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res

  end

  def deletequery (url)
    req = Net::HTTP::Delete.new(url.path, initheader = {'Content-Type' =>'application/json'})
    res = query(req, url, vars)
    return res

  end



  def create
    @toSend = { 
      "id" => :name,

    }.to_json

    sendHash = Hash.new
    sendHash["id"] = :repoid
    sendHash["display_name"] = :displayname if :displayname
    sendHash["description"] = :description if :description
    sendHash["notes"] = Hash.new
    sendHash["notes"]["_repo-type"] = :repotype
    #TODO add extra note fields
    sendHash.to_json
    pathvar = '/pulp/api/v2/repositories/'

    res = que

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
  @toSend = { 
    "display_name" => "test1"
  }.to_json


  url = URI.parse("https://pulpserver2.example.com/pulp/api/v2/repositories/tset1/")
  req = Net::HTTP::Put.new(url.path, initheader = {'Content-Type' =>'application/json'})
  req.basic_auth 'admin', 'admin'
  req.body = "#{@toSend}"
  sock = Net::HTTP.new(url.host, url.port)
  sock.use_ssl = true
  sock.verify_mode = OpenSSL::SSL::VERIFY_NONE
  res = sock.start {|http| http.request(req) }
  

  end

  def destroy
    #code to delete a repo
    if res.code ==202
      #output 
    end
  end
  def executequery(url, request, toSend)
    @uri = url.is_a?(::URI) ? url : ::URI.parse(url)
    req = Net::HTTP::@request.new(url.path, initheader = {'Content-Type' =>'application/json'})
    req.basic_auth 'admin', 'admin' #TODO refactor this
    req.body = "#{@toSend}"
    sock = Net::HTTP.new(uri.host, uri.port)
    sock.use_ssl = true
    sock.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = sock.start {|http| http.request(req) }
    return res
  end

end

