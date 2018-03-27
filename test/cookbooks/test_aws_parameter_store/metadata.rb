name             'test_aws_parameter_store' # ~FC064, ~FC065
maintainer       'Sturdy Networks'
maintainer_email 'devops@sturdy.cloud'
license          'All rights reserved'
description      'Test cookbook for aws_parameter_store'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'aws_parameter_store'
