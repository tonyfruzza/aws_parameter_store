default['inspec_user'] = case node['platform']
                         when 'centos'
                           'centos'
                         when 'amazon'
                           'ec2-user'
                         when 'ubuntu'
                           'ubuntu'
                         else
                           nil
                         end
