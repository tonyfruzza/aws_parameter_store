#
# Cookbook Name:: test_aws_parameter_store
# Recipe:: default
#
# Copyright 2017, Sturdy Networks
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'test_aws_parameter_store::_fix_tty' if node['platform'] == 'centos'
