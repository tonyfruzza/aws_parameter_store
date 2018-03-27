# aws_parameter_store

Chef recipe helper to retrieve data from [Amazon EC2 Systems Manager Parameter Store](https://aws.amazon.com/ec2/systems-manager/parameter-store/).

## Use

Ensure the instance has an IAM role with access to retrieve the parameters and use the helper following one of these examples:

### Individual Values

```
template '/tmp/myfile.properties' do
  variables(
    password: aws_parameter_store('us-east-1')['dev.mydatabase.password']
  )
end
```

### Multiple Values

#### Wildcard

```
my_params = aws_parameter_store('us-east-1')['dev.mydatabase.*']
# => {'dev.mydatabase.username' => 'foo', 'dev.mydatabase.password' => 'bar'}
template '/tmp/myfile.properties' do
  variables(
    password: my_params['dev.mydatabase.password']
  )
end
```

NOTE: The wildcard asterisk is only supported as the last item in the string

#### Array

```
my_params = aws_parameter_store('us-east-1')[%w(dev.mydatabase.username dev.mydatabase.password)]
# => {'dev.mydatabase.username' => 'foo', 'dev.mydatabase.password' => 'bar'}
template '/tmp/myfile.properties' do
  variables(
    password: my_params['dev.mydatabase.password']
  )
end
```

## Attributes

The region and decryption options can also be set via attributes, e.g.:
```
node.default['aws_parameter_store']['region'] = 'us-east-1'
node.default['aws_parameter_store']['decrypt_secure_strings'] = false
template '/tmp/myfile.properties' do
  variables(
    password: aws_parameter_store['dev.mydatabase.password']
  )
end
```

## Additional Attributes

### Retries/Backoff

The maximum number of retries and delay (for exponential backoff/retry of API calls) can be set via the `['aws_parameter_store']['max_retries']` & `['aws_parameter_store']['max_retry_sleep_seconds']` attributes.

## Credits

Heavy inspiration drawn from the [Citadel cookbook](https://github.com/poise/citadel).
