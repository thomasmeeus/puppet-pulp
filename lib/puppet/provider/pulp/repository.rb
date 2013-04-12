Puppet::Type.type(:pulp).provide(:repository) do
  
  def exists?
    begin
      #code to check is the repo exists
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

  def create
    #code to create a repo 
  end

  def update
    #code to update the credentials of a repo
  end

  def destroy
    #code to delete a repo
  end

end

