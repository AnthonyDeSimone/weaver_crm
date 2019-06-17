require 'geocoder'

class ServiceTicket < ActiveRecord::Base
  belongs_to :salesperson
  belongs_to :customer
  
  def pin_path
    if(self.materials_not_in_hand == 0)
      type = 'star'
    elsif(self.site_visit_required)
      type = 'flag'
    else
      type = 'pin'
    end
    
    case self.time_frame
    when 'fd'
      color = 'red'
    when 'hd'
      color = 'yellow'
    when 'thl'
      color = 'green'
    end
    
    return "#{color}_#{type}.png"
  end
  
  def time_frame_name
    names = {'fd' => 'Full Day', 'hd' => 'Half Day', 'thl' => '2 Hours or Less'}
    
    names[self.time_frame]
  end
  
  def get_coordinates(json=nil)
    json ||= JSON.load(self.info)
    response = ::Geocoder.search("#{json['ticket']['customer']['shipping']['address']} #{json['ticket']['customer']['shipping']['city']} #{json['ticket']['customer']['shipping']['state']} #{json['ticket']['customer']['shipping']['zip']}")

    if(!response.empty?)
      self.latitude   = response.first.data['geometry']['location']['lat']
      self.longitude  = response.first.data['geometry']['location']['lng']
    end
  end

  before_save do |record|
    json = JSON.load(record.info)
    get_coordinates(json)
  end  
end
