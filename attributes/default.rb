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

if node['ec2'] && node['ec2']['region'] # Chef 13+
  default['aws_parameter_store']['region'] = node['ec2']['region']
elsif node['ec2'] && node['ec2']['placement_availability_zone'] # Chef 12
  default['aws_parameter_store']['region'] = node['ec2']['placement_availability_zone'][0...-1]
else
  default['aws_parameter_store']['region'] = 'us-east-1'
end
default['aws_parameter_store']['decrypt_secure_strings'] = true
default['aws_parameter_store']['max_retries'] = 20
default['aws_parameter_store']['max_retry_sleep_seconds'] = 30.0
