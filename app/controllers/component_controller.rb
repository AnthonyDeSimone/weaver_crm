require 'net/https'
require 'uri'
 
class ComponentController < ApplicationController

  def image_proxy
    component = Component.find(params[:id])

    if(component.image_data)
      image = OpenStruct.new(body: Base64.decode64(component.image_data), content_type: component.image_content_type)
    else
      url = Component.find(params[:id]).image_url
      uri = URI.parse(Component.find(params[:id]).image_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      request = Net::HTTP::Get.new(uri.request_uri)
      
      
      image = http.request(request)

      if(image.code == "302")
        uri = URI.parse(image.header['location'])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        
        request = Net::HTTP::Get.new(uri.request_uri)
        
        image = http.request(request)
      end

      puts image.body
      puts "*" * 1000

      component.update(image_data: Base64.encode64(image.body), image_content_type: image.content_type)
    end

    send_data image.body, type: image.content_type, disposition: 'inline'
  end
end
