# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

  r = Component.create(name: "Single Door Vinyl Upcharge", form_type: "numeric", pricing_type: "each", small_price: 20, large_price: 20,
                      component_subcategory: ComponentSubcategory.where(name: 'Window Add-ons').first, requires_quantity: true, build_type: 0)
                      
  r.save
  
  StyleSizeFinish.all.each do |ssf|
    ssf.components << r  
  end

  r = Component.create(name: "Double Door Vinyl Upcharge", form_type: "numeric", pricing_type: "each", small_price: 40, large_price: 40,
                      component_subcategory: ComponentSubcategory.where(name: 'Window Add-ons').first, requires_quantity: true, build_type: 0)
                      
  r.save
  
  StyleSizeFinish.all.each do |ssf|
    ssf.components << r  
  end

=begin
ActiveRecord::Base.transaction do   
  Component.where(name: ["Shingle Color", "Body Color", "Door Color", "Shuter Color", "Trim Color"]).each do |component|
    component.component_options << ComponentOption.create(name: 'Custom', small_price: 0, large_price: 0)
    component.save
  end
end

=begin
SalesOrder.all.each do |order|
  if(order.production_order_created)
    order.update(build_status: :in_production)
  elsif(order.site_ready)
    order.update(build_status: :ready_to_process)  
  end
end

=begin
require 'dropbox'

  def long_share_url(path)   
    access_token = '4GcyA6lzV1kAAAAAAAAKewPJJwNRp-RD0-O3flBdGjCucGles3AYjySFNaKLQqcF'
    client = DropboxClient.new(access_token)
    session = DropboxOAuth2Session.new(access_token, nil)
    response = session.do_get "/shares/auto/#{client.format_path(path)}", {"short_url"=>false}
    Dropbox::parse_response(response)['url']
  end 

SalesOrder.all.each do |order|
  if(!order.dropbox_url)
    puts order.id
    order.update(dropbox_url: long_share_url("Weaver Barns/Sales Orders/Order #{order.id}")) 
  end
end


potentially_affected = SalesOrder.all.select {|o| !o.change_orders.empty?}
puts puts "potentials: "
puts potentially_affected.map(&:id)
bad_orders = []

potentially_affected.each do |order|
  #last_components = JSON.load(order.json_info)['data']['additions']
  
  list = [order, order.change_orders].flatten
  
  list.each_with_index do |change_order, i|
    break if i == (order.change_orders.size - 1)
    
    components = JSON.load(change_order.json_info)['data']['additions'] 
    
    components.each_with_index do |category, j|
    
      category['subsections'].each_with_index do |subcategory, k|
        next unless subcategory['show']
        
        subcategory['components'].andand.each_with_index do |component, m|
          next unless component['show']
          
          
          if(component['form_type'] == 'numeric' && component['image_url'] && component['value'] > 0)
          #  puts puts puts puts JSON.load(list[i+1].json_info)['data']['additions'][j]['subsections'][k]['components'][m] #[k][m]
           # puts puts puts puts JSON.load(list[i+1].json_info)['data']['additions'][j][subcategory].inspect #[m]
           # puts puts puts puts JSON.load(list[i+1].json_info)['data']['additions'][j][subcategory][component].inspect
            component = JSON.load(list[i+1].json_info)['data']['additions'][j]['subsections'][k]['components'][m]
            if(component['value'] == 0)
              bad_orders << "#{order.id}, CO: #{i+1}, part: #{component['name']} "
            end
          end
        end
      end
    end
  end

end
puts "actuals:"
puts bad_orders.uniq



  SalesOrder.all.each do |order|
    if(order.load_complete) 
      status = :Load_Complete
    elsif(order.scheduled) 
      status = :Scheduled
    elsif(order.working_on_site) 
      status = :Working_On_Site
    elsif(order.site_ready) 
      status = :Site_Ready
    elsif(order.site_ready) 
      status = :Site_Ready
    elsif(order.issued)
      status = :Live    
    else
     status = :Quote   
    end
    
    order.update(status: status)
  end


  r = Component.create(name: "Custom Shingles", form_type: "text", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Shingles').first, requires_quantity: false, build_type: 0)
                      
  r.save
  
  StyleSizeFinish.all.each do |ssf|
    ssf.components << r  
  end


=begin
  c1 = Component.where(name: "90\" Triple Door System").first
  c2 = Component.where(name: "108\" Triple Door System").first
  
  puts c1
  puts c2
  
  StyleSizeFinish.where(size: 'small').each do |ssf|
    ssf.components << c1  
    ssf.components << c2 
  end
  
  


SalesOrder.all.each do |order|
 # new_json = order.json_info.gsub('Vinyl Flowerbox Color', 'SUPER TEMP').gsub('Vinyl Shutter Color', 'Vinyl Flowerbox Color').gsub('SUPER TEMP', 'Vinyl Shutter Color')
  
  order.update(confirmed: true)
end
                          
=begin
require 'csv'
require 'pp'

class Object
  def yield_self
    yield self
  end

  def nil_if(&block)
    yield_self(&block) ? nil : self
  end
end

Salesperson.first.sales_teams << SalesTeam.find(30)
Salesperson.first.sales_teams << SalesTeam.find(31)

puts Salesperson.first.sales_teams


managers = [ {name:"Terry Shidel", team: "Amish Buildings", email: "tshidel@aol.com", pw: "0zm1p9ts"},
  {name:"Rod Geitgey", team: "Amish Country Furnishings", email: "rgeitgey@amishcountryfurnishings.com", pw: "q45nrurg"},
  {name:"Mike Fisher", team: "Amish Outdoor Showcase", email: "amishoutdoorshowcase@ymail.com", pw: "13s8ecam"},
  {name:"Brandon Gourley", team: "Amish Yard / Canonsburg", email: "bgourley@amishyard.com", pw: "e0o26kbg"},
  {name:"Mike Killen", team: "Amish Yard / Pittsburgh", email: "mkillen@amishyard.com", pw: "t0duoxmk"},
  {name:"Dale Hagler", team: "Apple Country Farm Market", email: "applecountry@sbcglobal.net", pw: "4t2zxzap"},
  {name:"Matt Crawford", team: "Backyard Solutions", email: "backyardsolutions@fuse.net", pw: "amjte7ba"},
  {name:"Dick & Yvonne", team: "Beach	Beach Excavating", email: "ybeach@windstream.net", pw: "1reeycyb"},
  {name:"Benjamin Bowers", team: "Bowers Landscaping", email: "bowerslandscaping@gmail.com", pw: "m7ro06bo"},
  {name:"Beau Brace", team: "Braces'", email: "info@bracepower.com", pw: "t0ji6qin"},
  {name:"Jim & Michele Varga", team: "Discount Stable", email: "crystal@discountstable.com", pw: "buasrvcr"},
  {name:"Angelia Kirkbride", team: "Infinitely Outdoors", email: "angelia@infinitelyoutdoors.com", pw: "8ueg6wan"},
  {name:"Christy Piatt", team: "Lansing Storage", email: "storagelansing@yahoo.com", pw: "rhdfkqst"},
  {name:"Ken Mueller", team: "Outdoor Wonders", email: "kwmueler@msn.com", pw: "8kb80vkw"},
  {name:"John Rumancik", team: "Parkviewe Landscaping", email: "hmdbr610@yahoo.com", pw: "hbsrduhm"},
  {name:"Dan Patrone", team: "Patrone Brothers Garden Center", email: "patrone7@live.com", pw: "bx5y7kpa"},
  {name:"Andy Schafer", team: "The Granary / Findlay", email: "andy@ggbarn.com", pw: "7ciuz5an"},
  {name:"Steve Schafer", team: "The Granary / Mt Cory", email: "steve@ggbarn.com", pw: "4t2zxzst"},
  {name:"Tom Paul", team: "Tom Paul Enterprises", email: "tompaul_06@yahoo.com", pw: "qau9jtto"},
  {name:"Mike Wright", team: "Trinity Homes", email: "mikewright.trinityhomesofwv@gmail.com", pw: "mgmkwnmi"},
  {name:"Mark Eastham", team: "Trinity Homes", email: "markeastham.trinityhomesofwv@gmail.com", pw: "oavpa7ma"}]
  internal = [{name:"Jim Light", team: "Weaver Barns", email: "weaverbarns@zoomtown.com", pw: "52dll4we"}]
  
  
managers.each do |manager|
  team = SalesTeam.where(name: manager[:team]).first_or_create
  
  Salesperson.create(name: manager[:name], email: manager[:email], sales_team: team,
                          password: manager[:pw], password_confirmation: manager[:pw], 
                          account_type: 'Dealer Sales Manager').save!
end

internal.each do |manager|
  team = SalesTeam.where(name: manager[:team]).first_or_create
  
  Salesperson.create(name: manager[:name], email: manager[:email], sales_team: team,
                          password: manager[:pw], password_confirmation: manager[:pw], 
                          account_type: 'Internal Sales Manager').save!
end


StructureStyleKey.destroy_all
Component.destroy_all
ComponentCategory.destroy_all
ComponentSubcategory.destroy_all
ComponentOption.destroy_all
Style.destroy_all
StyleKey.destroy_all
StyleSizeFinish.destroy_all
SalesOrder.destroy_all

Setting.destroy_all

Setting.create
SalesTeam.destroy_all
SalesTeam.create(name: 'Internal')
Salesperson.destroy_all
me = Salesperson.create(name: 'Anthony', email: 'anthony@mydesignforest.com', password: 'test1234', password_confirmation: 'test1234', sales_team: SalesTeam.first, account_type: 'Admin')
#me.skip_confirmation!
#me.skip_inviation = true
me.save!

puts me.inspect

['small', 'large'].each do |size|
  ['Premier', 'Deluxe', 'Vinyl', nil].each do |feature|
    StyleSizeFinish.create(size: size, feature: feature)
  end
end

CSV.foreach("Barns CSV.csv", {:headers => true}) do |row|
  zone_prices   = {}
  door_defaults = [ "4' Default Double Door", "5' Default Double Door",
                    "30\" Default Wood Door", "36\" Default Wood Door",
                    "36\" Default Steel Door"]
                    
  door_defaults.keep_if {|door| row[door] == 'Y'}
  
  1.upto(7) do |zone|
    current = "zone_#{zone}".to_sym

    zone_prices[current] = {}
    zone_prices[current][:prebuilt] = { :base =>  row["Z#{zone} Prebuilt"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                        :paint => row['PREBUILT Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                        :stain => row['PREBUILT Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f}

    zone_prices[current][:AOS]      = { :base =>  row["Z#{zone} AOS"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                        :paint => row["Z#{zone} AOS Painting"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                        :stain => row["Z#{zone} AOS Staining"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f}                                        
  end
  ln_ft = (row['Width'].to_i + row['Length'].to_i) * 2

  s = Style.where(name: row['Style']).first_or_create

  k = StyleKey.create(width: row['Width'], length: row['Length'], starting_roof_pitch: row['Pitch'].nil_if {|p| p == 'N/A'},
                      feature: row['Feature'], sq_feet: row['SQ FT'], ln_feet: row['LN FT'],
											zone_prices: zone_prices.to_json, door_defaults: door_defaults.to_json)

  if(["Cottage","Gable","Estate","Mini","Sugarcreek","Highland","Woodshed","Craftsman","Cambrel Cabin","Porch","Porch 12/12 Pitch","Leanto"].include?(row['Style']))
    StyleSizeFinish.where(size: 'small', feature: row['Feature']).first.style_keys << k
  else
    StyleSizeFinish.where(size: 'large', feature: row['Feature']).first.style_keys << k
  end

  k.save
  s.style_keys << k
  s.save
end

BUILD_TYPE_KEY = {nil => 0, '' => 0, 'aos' => 1, 'prebuilt' => 2}

CSV.foreach('form.csv', {:headers => true}) do |row|
  puts row['Field']
  puts row['Applicable'].include?('large')
  includes_small = row['Applicable'].include?('small')
  includes_large = row['Applicable'].include?('large')
  section = ComponentCategory.where(name: row['Section']).first_or_create
  subsection = ComponentSubcategory.where(name: row['Subsection'], component_category: section).first_or_create
  section.component_subcategories << subsection if !section.component_subcategories.include?(subsection)

  field = Component.where(component_subcategory: subsection, name: row['Field']).first

  build_type = row['Build Type'] 

  if(field.nil? || row['Duplicate'] == 'TRUE')
    field = Component.create(name: row['Field'], form_type: row['Type'], pricing_type: row['Pricing'], component_subcategory: subsection, 
                              requires_quantity: row['Quantity'] != 'FALSE', image_url: row['Image URL'], 
                              order_id: $., build_type: BUILD_TYPE_KEY[row['Build Type']])
  
    if(row['Feature'] == 'vinyl' )
      features = ['Vinyl']    
    elsif(row['Feature'] == 'Non-vinyl')
      features = ['Premier', 'Deluxe']    
    else
      features = ['Premier', 'Deluxe', 'Vinyl']
    end
    
    row['Applicable'].split(',').each do |size|
      features.each do |feature|
        StyleSizeFinish.where(size: size.strip, feature: feature).first.components << field
      end
    end
  end

  if(row['Type'] == 'numeric' || row['Type'] == 'text'|| row['Type'] == 'checkbox' || row['Type'] == 'check_price' || row['Type'] == 'check_length')
    field.small_price = row['Price'].andand.gsub(/$|,/, '').to_f  
    field.large_price = (row['Price_large'] || row['Price']).andand.gsub(/$|,/, '').to_f  
    field.save
  elsif((row['Type'] == 'select' || row['Type'] == 'radio' || row['Type'] == 'select_price') && !row['Option'].nil? && !row['Option'].empty?)
    field.component_options << ComponentOption.create(name: row['Option'], small_price: row['Price'].andand.gsub(/$|,/, '').to_f, 
                                                      large_price: (row['Price_large'] || row['Price']).andand.gsub(/$|,/, '').to_f,
                                                      image_url: row['Image URL'], order_id: $., build_type: BUILD_TYPE_KEY[row['Build Type']])
  end
end

c1 = Component.where(name: "90\" Triple Door System")


  cat = ComponentCategory.where(name: 'Doors').first
  c1 = Component.create(name: "90\" Triple Door System", form_type: "numeric", small_price: 1, large_price: 1, pricing_type: "each", component_subcategory: 
                    ComponentSubcategory.where(name: 'Extra Doors', component_category: cat).first, requires_quantity: false, build_type: 1)

#Ramps are not included as an option…. should be under Doors/Door Add-Ons (3’ Depth $75) (4’ Depth $100) (5’ Depth $125).
#Waste Removal needs to be in as an option under Misc options/$45.
#Carry Charge needs to be in under Misc Options for Assemble on site buildings $1.00 per ft beyond 100’.
ActiveRecord::Base.transaction do 
  cat = ComponentCategory.where(name: 'Misc Options').first
  c1 = Component.create(name: "Waste Removal", form_type: "checkbox", pricing_type: "each", small_price: 45, large_price: 45,
                  component_subcategory: ComponentSubcategory.where(name: 'Misc', component_category: cat).first, requires_quantity: false, build_type: 0)
  

  c2 = Component.create(name: "Carry Charge", form_type: "check_length", small_price: 1, large_price: 1, pricing_type: "ln_ft", component_subcategory: 
                    ComponentSubcategory.where(name: 'Misc', component_category: cat).first, requires_quantity: false, build_type: 1)
  
  cat = ComponentCategory.where(name: 'Doors').first
  r = Component.create(name: "Ramp", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Door Add-Ons', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
                      
  r.component_options << ComponentOption.create(name: "3' Depth Ramp", small_price: 75, large_price: 75)
  r.component_options << ComponentOption.create(name: "4' Depth Ramp", small_price: 100, large_price: 100)
  r.component_options << ComponentOption.create(name: "5' Depth Ramp", small_price: 125, large_price: 125)
  r.save
  

  cat = ComponentCategory.where(name: "90\" Triple Door System").first
  
  StyleSizeFinish.where(size: 'small').each do |ssf|
    ssf.components << c1  
  end
  
  r1 = Component.create(name: "Vinyl Shutter Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Window Accessories', component_category: cat).first, requires_quantity: false, build_type: 0)
  ['Black', 'Cherrywood', 'Chestnut Brown', 'Dove Gray', 'Green', 'Weatherwood', 'White'].each do |color|
    r1.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end

  r2 = Component.create(name: "Vinyl Flowerbox Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Window Accessories', component_category: cat).first, requires_quantity: false, build_type: 0)
  ['Black', 'Bordeaux', 'Bright White', 'Bugundy Red', 'Classic Blue', 'Clay', 'Federal Brown', 'Forest Green', 'Midnight Blue', 'Midnight Green',
  'Musket Brown', 'Tuxedo Gray', 'Wedgewood Blue', 'White', 'Wicker', 'Wineberry'].each do |color|
    r2.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end
    
  
  StyleSizeFinish.all.each do |ssf|
    ssf.components << r
    ssf.components << r1
    ssf.components << r2
    ssf.components << c1
    ssf.components << c2
  end


  old_trim = Component.where(name: 'Trim Color').first
  new_trim = old_trim.dup
  new_trim.component_subcategory = ComponentSubcategory.where(name: 'Stain').first
  
  old_trim.component_options.each do |option|
    new_trim.component_options << option
  end
  
  new_trim.save
  
  StyleSizeFinish.all.each do |ssf|
    ssf.components << new_trim
  end  

  puts :done  
end

ActiveRecord::Base.transaction do 
  paint_colors = ['Navajo White', 'Almond', 'Jamestown Red', 'Woodland Green', 'Wild Grasses', 'Avocado', 'Cream', 'Barn White', 'Jasper Gray', 'Steel Gray',
  'Charcoal', 'Dark Gray', 'Buckskin', 'Black', 'Clay', 'Shale', 'Brown', 'Bronze', 'Spice', 'Pinnacle Red', 'Mountain Red']

  cat = ComponentCategory.where(name: 'Paint & Stain').first

  #Vinyl Door Colors
  vinyl_door = Component.create(name: "Door Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Vinyl', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
  ['White', 'Linen', 'Gray', 'Pewter', 'Clay', 'Chateau', 'Everest', 'Birchwood', 'Cream', 'Antique White',
  'Sandpiper', 'Sienna', 'Sand', 'Mist', 'Sandalwood'].each do |color|
    vinyl_door.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end


  
  #Vinyl Trim Colors
  vinyl_trim = Component.create(name: "Trim Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Vinyl', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
  ['Almond', 'Antique White', 'Ash Gray', 'Black', 'Burgundy', 'Burnished Slate', 'Clay', 'Dark Bronze', 'Grecian Green', 'Light Stone', 'Musket Brown',
  'Ocean Blue', 'Royal Brown', 'Rustic Red', 'Sand', 'Sandalwood', 'Spice', 'Sterling Gray', 'Terratone', 'Tuxedo Gray', 'White', 'Birchwood', 'Cream',
  'Linen', 'Mist', 'Pewter', 'Sage', 'Sienna', 'White', 'Barn Red', 'Black/Royal Brown', 'Canyon', 'Camel', 'Desert Tan', 'Greystone Granite Gray', 'Pacific Blue',
  'Pueblo', 'Sandstone Saddle', 'Scotch Red'].each do |color|
    vinyl_trim.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end  
  
  vinyl_trim.component_subcategory = ComponentSubcategory.where(name: 'Vinyl').first



  #Paint Door Colors
  paint_door = Component.create(name: "Door Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Paint', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
  paint_colors.each do |color|
    paint_door.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end

  paint_door.component_subcategory = ComponentSubcategory.where(name: 'Paint').first
  
  
  
  #Paint Shutter Colors
  paint_shutter = Component.create(name: "Shutter Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Paint', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
  paint_colors.each do |color|
    paint_shutter.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end  

  paint_shutter.component_subcategory = ComponentSubcategory.where(name: 'Paint').first



  #Stain Door Colors
  stain_door = Component.create(name: "Door Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Stain', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
  (paint_colors + ['Natural', 'Caramel', 'Bronze', 'Bark', 'Chestnut', 'Smoke']).each do |color|
    stain_door.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end

  stain_door.component_subcategory = ComponentSubcategory.where(name: 'Stain').first
  
  
  
  #Stain Shutter Colors
  stain_shutter = Component.create(name: "Shutter Color", form_type: "select", pricing_type: "each", 
                      component_subcategory: ComponentSubcategory.where(name: 'Stain', component_category: cat).first, requires_quantity: false, build_type: 0)
                      
  (paint_colors + ['Natural', 'Caramel', 'Bronze', 'Bark', 'Chestnut', 'Smoke']).each do |color|
    stain_shutter.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end  

  stain_shutter.component_subcategory = ComponentSubcategory.where(name: 'Paint').first

  StyleSizeFinish.all.each do |ssf|
    ssf.components << paint_door
    ssf.components << paint_shutter
    ssf.components << vinyl_door
    ssf.components << vinyl_trim
    ssf.components << stain_door
    ssf.components << stain_shutter
  end
  
  
  #Additional Stain Trim Colors
  ['Natural', 'Caramel', 'Bronze', 'Bark', 'Chestnut', 'Smoke'].each do |color|
    stain_trim = Component.where(name: 'Trim Color', component_subcategory: ComponentSubcategory.where(name: 'Stain', component_category: cat)).first
    puts stain_trim.inspect
    stain_trim.component_options << ComponentOption.create(name: color, small_price: 0, large_price: 0)
  end    
  
end  
  
#SalesOrder.destroy_all
=end
