require 'net/https'
require 'uri'
 
class ComponentOptionController < ApplicationController
  def image_proxy
    component_option = ComponentOption.find(params[:id])

    if(component_option.image_data)
      image = OpenStruct.new(body: Base64.decode64(component_option.image_data), content_type: component_option.image_content_type)
    else
      url = ComponentOption.find(params[:id]).image_url
      uri = URI.parse(ComponentOption.find(params[:id]).image_url)
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

      component_option.update(image_data: Base64.encode64(image.body), image_content_type: image.content_type)      
    end

    send_data image.body, type: image.content_type, disposition: 'inline'
  end
end
