require 'aws-sdk'

module Antenna
  class Distributor::S3
    def initialize(access_key_id, secret_access_key, region, endpoint = nil)
      options = {
        :access_key_id      => access_key_id,
        :secret_access_key  => secret_access_key,
        :region             => region || "us-east-1",
        :force_path_style   => true
      }
      options[:endpoint] = endpoint if endpoint
      @s3 = Aws::S3::Resource.new(options)
      p '*' * 1000
      p 'We have initialized the antenna distributor through the Canvas forked project.'
    end

    def setup(ipa_file, options = {})
      @options = options
      @options[:expire] = @options[:expire] ? @options[:expire].to_i : 86400
      @options[:acl] ||= "private"

      if @options[:create]
        puts "Creating bucket #{@options[:bucket]} with ACL #{@options[:acl]}..."

        @s3.create_bucket({
          :bucket => @options[:bucket],
          :acl    => @options[:acl],
        })
      end
    end

    def distribute(data, filename, content_type)
      puts "Distributing #{filename} ..."

      object = @s3.bucket(@options[:bucket]).put_object({
        :key          => filename,
        :content_type => content_type,
        :body         => data,
        :acl          => @options[:acl]
      })

      if @options[:public]
        URI.parse(object.public_url)
      else
        URI.parse(object.presigned_url(:get, { :expires_in => @options[:expire] }))
      end
    end
  end
end
