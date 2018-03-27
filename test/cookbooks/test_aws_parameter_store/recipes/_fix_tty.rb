#
# Cookbook Name:: test_aws_parameter_store
# Recipe:: _fix_tty
#
# Copyright 2017, Sturdy Networks
#
# All rights reserved - Do Not Redistribute
#

# Stops errors:
# Failed to complete #verify action: [Sudo failed: Sudo requires a TTY...
file '/etc/sudoers.d/inspec' do
  content "#{node['inspec_user']} ALL=(root) NOPASSWD: ALL\n"\
          "Defaults!ALL !requiretty\n"
  owner 'root'
  group 'root'
  mode 00640
end
