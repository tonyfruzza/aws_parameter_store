#
# Copyright 2013-2016, Balanced, Inc.
# Copyright 2016, Noah Kantrowitz
# Copyright 2017, Sturdy Networks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'aws-sdk'
require 'retries'

class SSMParameterStore
  attr_reader :region, :decrypt_secure_strings

  def initialize(node, region = nil, decrypt_secure_strings = nil, max_retries = nil, max_retry_sleep_seconds = nil)
    @node = node
    @region = region || node['aws_parameter_store']['region']
    @decrypt_secure_strings = decrypt_secure_strings || node['aws_parameter_store']['decrypt_secure_strings']
    @max_retries = max_retries || node['aws_parameter_store']['max_retries']
    @max_retry_sleep_seconds = max_retry_sleep_seconds || node['aws_parameter_store']['max_retry_sleep_seconds']
    @throttling_exceptions = [Aws::SSM::Errors::ThrottlingException]
  end

  def [](param_name)
    ssm_client = Aws::SSM::Client.new(region: @region)
    params = {}
    if param_name.respond_to?(:each) # i.e. an array
      Chef::Log.debug("aws_parameter_store: multi parameter lookup for \"#{param_name}\" starting in #{@region}")
      resp = with_retries(max_tries: @max_retries,
                          max_sleep_seconds: @max_retry_sleep_seconds,
                          rescue: @throttling_exceptions) do
        ssm_client.get_parameters(
          names: param_name,
          with_decryption: @decrypt_secure_strings
        )
      end
      resp.parameters.each do |i|
        params[i.name] = i.value
      end
      return params
    elsif param_name.end_with? '*'
      params_to_retrieve = []
      Chef::Log.debug("aws_parameter_store: wildcard search for #{param_name} starting in #{@region}")
      matched_parameters = with_retries(max_tries: @max_retries,
                                        max_sleep_seconds: @max_retry_sleep_seconds,
                                        rescue: @throttling_exceptions) do
        ssm_client.describe_parameters(
          filters: [
            {
              key: 'Name',
              values: [param_name.chomp('*')],
            },
          ]
        )
      end
      matched_parameters.parameters.each do |i|
        params_to_retrieve << i.name
      end
      resp = with_retries(max_tries: @max_retries,
                          max_sleep_seconds: @max_retry_sleep_seconds,
                          rescue: @throttling_exceptions) do
        ssm_client.get_parameters(
          names: params_to_retrieve,
          with_decryption: @decrypt_secure_strings
        )
      end
      resp.parameters.each do |i|
        params[i.name] = i.value
      end
      return params
    else # single value
      Chef::Log.debug("aws_parameter_store: single parameter lookup for \"#{param_name}\" starting in #{@region}")
      resp = with_retries(max_tries: @max_retries,
                          max_sleep_seconds: @max_retry_sleep_seconds,
                          rescue: @throttling_exceptions) do
        ssm_client.get_parameters(
          names: [param_name],
          with_decryption: @decrypt_secure_strings
        )
      end
      return resp.parameters[0].value
    end
  end

  # Helper module for the DSL extension.
  #
  # @since 1.0.0
  # @api private
  module ChefDSL
    def aws_parameter_store(region = nil, decrypt_secure_strings = nil, max_retries = nil, max_retry_sleep_seconds = nil)
      SSMParameterStore.new(node, region, decrypt_secure_strings, max_retries, max_retry_sleep_seconds)
    end
  end
end

# Patch our DSL extension into Chef.
# @api private
class Chef
  class Recipe
    include SSMParameterStore::ChefDSL
  end

  class Resource
    include SSMParameterStore::ChefDSL
  end

  class Provider
    include SSMParameterStore::ChefDSL
  end
end
