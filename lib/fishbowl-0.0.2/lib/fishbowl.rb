require 'socket'
require 'base64'
require 'singleton'
require 'digest/md5'

require 'nokogiri'

require 'fishbowl/ext'

require 'fishbowl/version'
require 'fishbowl/errors'
require 'fishbowl/requests'
require 'fishbowl/objects'

module Fishbowl # :nodoc:
  class Connection
    include Singleton
    extend Requests
   
    def self.connect(options = {})
      raise Fishbowl::Errors::MissingHost if options[:host].nil?

      @host = options[:host]
      @port = options[:port].nil? ? 28192 : options[:port]
      @connection = TCPSocket.new @host, @port
      @key = nil
      self.instance
    end
    
    def self.debug
      @debug = true
    end

    def self.login(options = {})
      raise Fishbowl::Errors::ConnectionNotEstablished if @connection.nil?
      raise Fishbowl::Errors::MissingUsername if options[:username].nil?
      raise Fishbowl::Errors::MissingPassword if options[:password].nil?

      @username, @password = options[:username], options[:password]

      code, message, _ = Fishbowl::Objects::BaseObject.new.send_request(login_request, 'LoginRs')

      Fishbowl::Errors.confirm_success_or_raise(code.to_i)

      self.instance
    end

    def self.host
      @host
    end

    def self.port
      @port
    end

    def self.username
      @username
    end

    def self.password
      @password
    end

    def self.send(request, expected_response = 'FbiMsgRs')
      write(request)
      get_response(expected_response)
    end

    def self.close
      @connection.close
      @connection = nil
    end

  private

    def self.login_request
      Nokogiri::XML::Builder.new do |xml|
        xml.request {
          xml.LoginRq {
            xml.IAID          "121"
            xml.IAName        "Ruby Fishbowl 2"
            xml.IADescription "Ruby Fishbowl 2"
            xml.UserName      @username
            xml.UserPassword  encoded_password
          }
        }
      end
    end

    def self.encoded_password
      Base64.encode64(Digest::MD5.digest(@password)).chomp
    end

    def self.write(request)
      body = request.to_xml
      size = [body.size].pack("L>")
      puts body if @debug
      @connection.write(size)
      @connection.write(body)
    end

    def self.get_response(expectation)
      length = @connection.recv(4)
      length = length.unpack("L>").join('').to_i
      response = Nokogiri::XML.parse(@connection.recv(length, Socket::MSG_WAITALL))
      
      secondary_code, status_message = nil, nil
      
      puts response if @debug
      if(@key.nil?)
        @key = response.xpath("//Ticket/Key/text()").first
      end
  
      if(!response.xpath("//FbiMsgsRs/@statusCode").first.nil?)
        primary_code = response.xpath("//FbiMsgsRs/@statusCode").first.value
        Fishbowl::Errors.confirm_success_or_raise(primary_code.to_i)
      end
      
      if(!response.xpath("//#{expectation}/@statusCode").first.nil?)    
        secondary_code = response.xpath("//#{expectation}/@statusCode").first.value.to_i
      end
      
      if(!response.xpath("//#{expectation}/@statusMessage").first.nil?)
        status_message = "Code: #{secondary_code}: " + response.xpath("//#{expectation}/@statusMessage").first.value
      end
      
      if(secondary_code)
        Fishbowl::Errors.confirm_success_or_raise(secondary_code.to_i, status_message)
      end
      
      [primary_code, status_message, response]
    end
  end
end
