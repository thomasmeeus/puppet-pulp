Puppet::Type.type(:pulp).provide(:repository) do
require 'rubygems'
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

  def exists?
    begin
      #code to check is the repo exists
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def create
@toSend = { 
            "id" => "tset1",
}.to_json




    url = URI.parse("https://pulpserver2.example.com/pulp/api/v2/repositories/")
    req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
    req.basic_auth 'test-user', 'test'
    req.body = "#{@toSend}"
    sock = Net::HTTP.new(url.host, url.port)
    sock.use_ssl = true
    sock.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = sock.start {|http| http.request(req) }
    
    fail "Couldn't create repo: #{res.code} #{res.body}" unless res.kind_of? Net::HTTPSuccess
  end

  def update
    #code to update the credentials of a repo
  end

  def destroy
    #code to delete a repo
  end

end

