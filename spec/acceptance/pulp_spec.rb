require 'spec_helper_acceptance'

describe 'pulp' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
         class { 'pulp':
           pulp_version => '2',
           pulp_server  => true,
           pulp_admin   => true,
           repo_enabled => true,
           different_location = false
         }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('pulp-server') do
      it { should be_installed }
    end

    describe package('pulp-admin') do
      it { should be_installed }
    end
  end
end
