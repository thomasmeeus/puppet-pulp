#!/usr/bin/env rspec

require 'spec_helper'

describe 'pulp' do
  it { should contain_class 'pulp' }
end
