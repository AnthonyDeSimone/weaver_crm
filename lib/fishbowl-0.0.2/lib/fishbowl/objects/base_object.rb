module Fishbowl::Objects
  class BaseObject
    attr_accessor :ticket

    def send_request(request, expected_response = 'FbiMsgRs', options = {})
      code, message, response = Fishbowl::Connection.send(build_request(request, options), expected_response)
      Fishbowl::Errors.confirm_success_or_raise(code.to_i)
      [code, message, response]
    end
    
  protected

    def self.attributes
      %w{ID}
    end

    def parse_attributes    
      self.class.attributes.each do |field|
        field = field.to_s

        if field == 'ID'
          instance_var = 'db_id'
        elsif field.match(/^[A-Z]{3,}$/)
          instance_var = field.downcase
        else
          instance_var = field.gsub(/ID$/, 'Id').underscore
        end
        instance_var = '@' + instance_var

        value = @xml.xpath("//#{field}").first.nil? ? nil : @xml.xpath("//#{field}").first.inner_text
         if(value == "true")
          value = true
        elsif(value == "false")
          value = nil
        end

        instance_variable_set(instance_var, value)
      end
    end

  private  
    def type_check(xml, key, value, inner = false)   
      if(value.is_a? Hash)
        xml_hash(xml, key, value, inner)
      elsif(value.is_a? Array)
        xml_array(xml, key, value)
      else
        xml.send(key.to_tag, value)
      end
    end
  
    def xml_hash(xml, key, value, inner)
      if(inner)
        value.each do |key2, value2|
          type_check(xml, key2, value2)
        end      
      else   
        xml.send(key.to_tag){
          value.each do |key2, value2|
            type_check(xml, key2, value2)
          end
        }   
      end
    end
    
    def xml_array(xml, key, value)

      xml.send(key.to_tag){
             
        value.each do |value2|
          if(value2.is_a? String)
            xml.send(key.to_tag.gsub(/s\Z/, ''), value2)     
          elsif(value2.is_a? Array)
            xml.send(key.to_tag.gsub(/s\Z/, ''), value.join(', '))   
          else
            type_check(xml, key, value2, true)
          end
        end
      }   
    end
  
    def build_request(request, options)
      Nokogiri::XML::Builder.new do |xml|
        xml.FbiXml {
          if @ticket.nil?
            xml.Ticket
          else
            xml.Ticket{ 
              xml.Key @ticket
            }
          end

          xml.FbiMsgsRq {
            if request.respond_to?(:to_xml)
              xml << request.doc.xpath("request/*").to_xml
            else
              xml.send(request.to_s) {
                if(options.is_a? String)
                  xml.send(options)
                else            
                  options.each_pair do |key, value|
                    value = "true" if(value == true)
                    value = "false" if(value == false)
                    
                    type_check(xml, key, value)
                  end 
                end
              }
            end
          }
        }
      end
    end

  end
end
