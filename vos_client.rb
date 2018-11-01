#!/usr/bin/env ruby
require 'aws-sdk-s3'

# NOTE necessary environment variable:
# AWS_ACCESS_KEY_ID = <vos access key>
# AWS_SECRET_ACCESS_KEY = <vos secret key>
# They can be found here: https://nopaste2.linecorp.com/entry/c5481ee0-b9a4-45ca-97a1-08b6013ba18c
# endpoint https://line-objects-dev.com
# AWS Documentation: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Object.html#upload_file-instance_method
# Slack discussion with Verda developpers: https://line-enterprise.slack.com/archives/C98Q0P30C/p1541054000128400

Endpoint = 'https://line-objects-dev.com'

class VOSClient
    def initialize(bucket = 'cartridge', region = 'tokyo')
      @s3 = Aws::S3::Resource.new(region: region, endpoint: Endpoint)
      @bucket_name = bucket
      @bucket = @s3.bucket(bucket)
    end

    def list_buckets
        @s3.buckets.limit(50).each do |b|
          puts "#{b.name}"
        end
    end

    def upload_file(file_path, name)
        obj = @bucket.object(name)
        obj.upload_file(file_path)
    end

    def get_file(key, file_path)
        # Create the object to retrieve
        obj = @bucket.object(key)

        # Get the item's content and save it to a file
        obj.get(response_target: file_path)
    end
end

# TESTS
client = VOSClient.new()
client.list_buckets
client.get_file('emoji.txt', '/tmp/my-item.txt')


# This `upload_file` always return an error `Aws::S3::Errors::SignatureDoesNotMatch`
file = File.open("/tmp/my-item.txt")
client.upload_file(file, 'my-item.txt')
