shelves = {
"8' x 1' (2 x 4 Joists)" => 50,
"10' x 1' (2 x 4 Joists)" => 55,
"12' x 1' (2 x 6 Joists)" => 75,
"14' x 1' (2 x 6 Joists)" => 85,
"16' x 1' (2 x 6 Joists)" => 95,
"8' x 2' (2 x 4 Joists)" => 60,
"10' x 2' (2 x 4 Joists)" => 70,
"12' x 2' (2 x 6 Joists)" => 100,
"14' x 2' (2 x 6 Joists)" => 115,
"16' x 2' (2 x 6 Joists)" => 125,
"8 x 2 work bench" => 155,
"10 x 2 work bench" => 175,
"12 x 2 work bench" => 195
}

shelves.each_pair do |name, price|
  puts name
  Component.find_by_name(name).update(small_price: price)
end

lofts = {
 "8' x 4' (2 x 4 Joists)" => 80,
  "10' x 4' (2 x 4 Joists)" => 90,
  "12' x 4' (2 x 6 Joists)" => 140,
  "14' x 4' (2 x 8 Joists)" => 160,
  "16' x 4' (2 x 8 Joists)" => 180
}

overheads.each_pair do |name, price|
  puts name
  ComponentOption.find_by_name(name).update(small_price: price)
end


#########################################
#### DOORS





overheads = {
"8'W x 7'H Overhead Door - Non-Insulated" => 1050.00, 
"8'W x 7'H Overhead Door - Economy Insulated" => 1275.00, 
"8'W x 7'H Overhead Door - Standard Insulated" => 1395.00, 
"8'W x 7'H Overhead Door - Carriage House Style" => 1850.00, 
  
  
"9'W x 7'H Overhead Door - Non-Insulated" => 1100.00, 
"9'W x 7'H Overhead Door - Economy Insulated" => 1310.00, 
"9'W x 7'H Overhead Door - Standard Insulated" => 1440.00, 
"9'W x 7'H Overhead Door - Carriage House Style" => 1895.00, 
 
"9'W x 8'H Overhead Door - Non-Insulated" => 1235.00, 
"9'W x 8'H Overhead Door - Economy Insulated" => 1380.00, 
"9'W x 8'H Overhead Door - Standard Insulated" => 1615.00, 
"9'W x 8'H Overhead Door - Carriage House Style" => 2070.00, 
   
"10'W x 7'H Overhead Door - Non-Insulated" => 1255.00, 
"10'W x 7'H Overhead Door - Economy Insulated" => 1430.00, 
"10'W x 7'H Overhead Door - Standard Insulated" => 1600.00, 
"10'W x 7'H Overhead Door - Carriage House Style" => 2055.00, 
  
"10'W x 8'H Overhead Door - Non-Insulated" => 1315.00, 
"10'W x 8'H Overhead Door - Economy Insulated" => 1525.00, 
"10'W x 8'H Overhead Door - Standard Insulated" => 1715.00, 
"10'W x 8'H Overhead Door - Carriage House Style" => 2170.00, 
  
"12'W x 7'H Overhead Door - Non-Insulated" => 1360.00, 
"12'W x 7'H Overhead Door - Economy Insulated" => 1685.00, 
"12'W x 7'H Overhead Door - Standard Insulated" => 1930.00, 
"12'W x 7'H Overhead Door - Carriage House Style" => 2585.00, 
 
 
"12'W x 8'H Overhead Door - Non-Insulated" => 1440.00, 
"12'W x 8'H Overhead Door - Economy Insulated" => 1795.00, 
"12'W x 8'H Overhead Door - Standard Insulated" => 2075.00, 
"12'W x 8'H Overhead Door - Carriage House Style" => 2735.00, 

  
"16'W x 7'H Overhead Door - Non-Insulated" => 1645.00, 
"16'W x 7'H Overhead Door - Economy Insulated" => 1985.00, 
"16'W x 7'H Overhead Door - Standard Insulated" => 2095.00, 
"16'W x 7'H Overhead Door - Carriage House Style" => 2945.00, 
  
"16'W x 8'H Overhead Door - Non-Insulated" => 1735.00, 
"16'W x 8'H Overhead Door - Economy Insulated" => 2130.00, 
"16'W x 8'H Overhead Door - Standard Insulated" => 2330.00, 
"16'W x 8'H Overhead Door - Carriage House Style" => 3180.00, 
  
extras = {
"Overhead Door Opener w/ One Remote" => 495.00, 
"Additional Remote Single Line Select" =>  59.00, 

}


# New doors

new_doors = {"30\" #200-SD Wood Single Door" => 115.00,
"36\" #200-SD Wood Single Door" => 115.00,
"4' #200 Wood Double Door" => 190.00,
"5' #200 Wood Double Door" => 190.00,
"6' #200 Wood Double Door" => 275.00,
"7' #200 Wood Double Door" => 360.00,
 
"36\" #201-SD Wood Single Door" => 135.00,
"5' #201-A Wood Double Door" => 230.00,
"6' #201-A Wood Double Door" => 315.00,
 
"30\" #101-SD Wood Single Door" => 215.00,
"36\" #101-SD Wood Single Door" => 215.00,
"5' #101-SW Wood Double Door" => 390.00,
"6' #101-SW Wood Double Door" => 475.00,
 
"30\" #102-SD Wood Single Door" => 210.00,
"36\" #102-SD Wood Single Door" => 210.00,
"4' #102-TW Wood Double Door" => 380.00,
"5' #102-TW Wood Double Door" => 380.00,
"6' #102-TW Wood Double Door" => 465.00,
"7' #102-TW Wood Double Door" => 550.00,
 
"30\" #202-SD Wood Single Door" => 200.00,
"36\" #202-SD Wood Single Door" => 200.00,
"4' #202-TW Wood Double Door" => 360.00,
"5' #202-TW Wood Double Door" => 360.00,
"6' #202-TW Wood Double Door" => 445.00,
"7' #202-TW Wood Double Door" => 530.00,
 
"36\" #103-SD Wood Single Door" => 220.00,
"5' #103-AW Wood Double Door" => 400.00,
"6' #103-AW Wood Double Door" => 485.00,
 
"30\" #203-SD Wood Single Door" => 225.00,
"36\" #203-SD Wood Single Door" => 225.00,
"5' #203-LW Wood Double Door" => 410.00,
"6' #203-LW Wood Double Door" => 495.00}

last_id = nil

door_4 = ComponentOption.find(1229)
door_5 = ComponentOption.find(1230)
door_6 = ComponentOption.find(1231)
door_7 = ComponentOption.find(1232)
door_30 = ComponentOption.find(1234)
door_36 = ComponentOption.find(1235)

## STIL NEED IMAGES
new_doors.each_pair do |name, price|

  c = ComponentSubcategory.find_by_name("Extra Doors").components.create(name: name, small_price: price, form_type: "numeric", pricing_type: "each")
  c.update(order_id: c.id)
  last_id = c.id


  case name 
  when /\A4'/
    original = door_4
  when /\A5'/
    original = door_5    
  when /\A6'/
    original = door_6    
  when /\A7'/
    original = door_7    
  when /\A30"/
    original = door_30
  when /\A36"/
    original = door_36  
  end 

  c.update(image_url: original.image_url, image_data: original.image_data, image_content_type: original.image_content_type)

  c.style_size_finishes = StyleSizeFinish.joins(style_keys: :style).where("styles.pavillion": false).distinct
end

Component.find_by_name("90\" Triple Door System").update(small_price: 680.00, order_id: last_id) 
Component.find_by_name("108\" Triple Door System").update(small_price: 830.00, order_id: last_id + 1) 


overhead_lites = {
  "8'W x 7'H Overhead Door" => 297,
  "9'W x 7'H Overhead Door" => 297,
  "9'W x 8'H Overhead Door" => 297,
  "10'W x 7'H Overhead Door" => 372,
  "10'W x 8'H Overhead Door" => 372,
  "12'W x 7'H Overhead Door" => 447,
  "12'W x 8'H Overhead Door" => 447,
  "16'W x 7'H Overhead Door" => 595,
  "16'W x 8'H Overhead Door" => 595,
}

overhead_lites.each_pair do |parent, price|
  puts parent
  id = Component.find_by_name(parent).id
  Component.where(id: id+1, name: "Window Lites for Non, Economy, or Standard Insulated Doors").update_all(small_price: price)
end



Component.where(name: "4'").update_all(name: "4' #100 Wood Double Door", small_price: 190)
Component.where(name: "5'").update_all(name: "5' #100 Wood Double Door", small_price: 190)
Component.where(name: "6'").update_all(name: "6' #100 Wood Double Door", small_price: 275)
Component.where(name: "7'").update_all(name: "7' #100 Wood Double Door", small_price: 360)

ComponentOption.where(name: "4'").update_all(name: "4' #100 Wood Double Door")
ComponentOption.where(name: "5'").update_all(name: "5' #100 Wood Double Door")
ComponentOption.where(name: "6'").update_all(name: "6' #100 Wood Double Door")
ComponentOption.where(name: "7'").update_all(name: "7' #100 Wood Double Door")

ComponentOption.where(name: "30\"").update_all(name: "30\" #100-SD Wood Double Door")
ComponentOption.where(name: "36\"").update_all(name: "46\" #100-SD Wood Double Door")

ComponentOption.where(name: "36\" 9-lite Steel Entry Door").update_all(name: "36\" 9-lite Steel Entry Door (24 gauge)")
c1 = ComponentOption.where(name: "36\" 9-lite Steel Entry Door (24 gauge)")
c2 = c1.dup.update(name: "36\" 9-lite Steel Entry Door (24 gauge)")
c2.style_size_finishes = c1.style_size_finishes


ComponentSubcategory.find_by_name("Steel Entry Door").components.update_all(active: false)

#################################
#### WINDOWS

# Delte these guys
Component.where(name: "6-lite Wooden Window").update_all(active: false)

# Add a new 2x5
c1 = Component.find_by_name("2' x 4' Single Hung with screen & grids")
c = c1.dup
c.update(name: "2' x 5' Single Hung with screen & grids")
c.style_size_finishes = c1.style_size_finishes
c.component_options.create(name: "2' x 5' Single Hung with screen & grids - White", small_price: 175)
c.component_options.create(name: "2' x 5' Single Hung with screen & grids - Brown", small_price: 175)

window_prices = {
"2' x 2' Single Hung with screen & grids - White" => 95.00, 
"2' x 2' Single Hung with screen & grids - Brown" => 95.00, 
"2' x 3' Single Hung with screen & grids - White" => 115.00, 
"2' x 3' Single Hung with screen & grids - Brown" => 115.00, 
"2' x 4' Single Hung with screen & grids - White" => 160.00, 
"2' x 4' Single Hung with screen & grids - Brown" => 160.00, 
"2' x 3' Window with Transom - White" => 195.00, 
"2' x 3' Window with Transom - Brown" => 195.00, 
"2' x 3' Vinyl SINGLE HUNG Window with screen & grids - White" => 235.00, 
"2' x 3' Vinyl SINGLE HUNG Window with screen & grids - Almond" => 325.00, 
"2' x 3' Vinyl SINGLE HUNG Window with screen & grids - Clay" => 325.00, 
"2' x 4' Vinyl SINGLE HUNG Window with screen & grids - White" => 280.00, 
"2' x 4' Vinyl SINGLE HUNG Window with screen & grids - Almond" => 370.00, 
"2' x 4' Vinyl SINGLE HUNG Window with screen & grids - Clay" => 370.00, 
"3' x 4' Vinyl SINGLE HUNG Window with screen & grids - White" => 305.00, 
"3' x 4' Vinyl SINGLE HUNG Window with screen & grids - Almond" => 395.00, 
"3' x 4' Vinyl SINGLE HUNG Window with screen & grids - Clay" => 395.00,
"Transom Windows - White" => 85.00, 
"Transom Windows - Brown" => 85.00,
}

window_prices.each_pair do |name, price|
  puts name
  ComponentOption.find_by_name(name).update(small_price: price)
end

Component.find_by_name("2' x 2' Bubble Skylight").update(small_price: 115)
Component.find_by_name("2' x 2' Skylight - installed in metal roof").update(small_price: 230)


####################################
# Flowerboxes


ss = Component.find_by(name: "Cedar Shutter Set")
ss.update(name: "Wood Shutter Set", small_price: 60)
ssz = ss.dup
ssz.update(name: "Wood Shutter Set (Z strap)", order_id: 124)
ssz.style_size_finishes = ss.style_size_finishes

Component.find_by(name: "Cedar Flowerbox").update(name: "Wood Flowerbox", order_id: 125, small_price: 55)
Component.find_by(name: "Cedar Shutter Set & Flowerbox").update(name: "Wood Shutter Set & Flowerbox", order_id: 126, small_price: 115)
Component.find_by(name: "Vinyl Shutter Set Panel Style").update(order_id: 127, small_price: 70)
Component.find_by(name: "Vinyl Flowerbox").update(order_id: 128, small_price: 60)
Component.find_by(name: "Vinyl Shutter Set & Flowerbox").update(order_id: 129, small_price: 130)



################################
### Cupolas


ComponentOption.where(name: "Windowpane Style").update_all(small_price: 340)
ComponentOption.where(name: "Traditional Style").update_all(small_price: 340)
Component.where(name: "Copper Colored Metal Roof").update_all(small_price: 100)
curved = Component.find_by(name: "Copper Colored Metal Roof").dup
curved.update(small_price: 130)
curved.style_size_finishes = StyleSizeFinish.joins(style_keys: :style).where("styles.pavillion": false)




Component.where(name: "Higher Sidewall for Duratemp Buildings").where("created_at > ?", 1.month.ago).update_all(small_price: 6.35)
Component.where(name: "Higher Sidewall for Solid Pine Buildings").where("created_at > ?", 1.month.ago).update_all(small_price: 6.95) 
Component.where(name: "Higher Sidewall  for Vinyl Buildings").where("created_at > ?", 1.month.ago).update_all(small_price: 8.2) 


steps = {"Straight Steps with Hand Rail	Single" => 475.00,
"Loft Steps with Landing and Hand Rail" => 690.00 ,
"1 x 4 Pine Railing for Loft & Steps" => 695.00 ,
"Risers on Steps" => 145.00, 
"Attic Ladder" => 295.00,
"Stair Ladder" => 365.00 }

steps.each_pair do |name, price|
  c = ComponentSubcategory.find_by_name("Steps").components.create(name: name, small_price: price, pricing_type: "each", form_type: 'numeric')

  StyleSizeFinish.joins(style_keys: :style).where("styles.large_garage": true).distinct.each do |ssf|
    ssf.components << c
  end
end



steel_doors = [['36" 6-Panel Economy Steel Entry Door','36" 6-Panel Steel Entry Door (24 gauge)', 390],
['36" 9-lite Economy Steel Entry Door', '36" 9-lite Steel Entry Door (24 gauge)', 525],
['36" 6-Panel Steel Entry Door', '36" 6-Panel Steel Entry Door (22 gauge)', 540],
['36" 9-lite Steel Entry Door', '36" 9-lite Steel Entry Door (22 gauge)', 715],
['36" 15-lite Steel Entry Door', '36" 15-lite Steel Entry Door (22 gauge)', 755],
['36" 3-lite Steel Entry Door w/ Dentil Shelf', '36" 3-lite Steel Entry Door w/ Dentil Shelf (22 gauge)', 1015],
['72" 6-panel Steel Entry Door', '72" 6-panel Steel Entry Door (22 gauge)', 875],
['72" 9-lite Steel Entry Door', '72" 9-lite Steel Entry Door (22 gauge)', 1250],
['72" 15-lite Steel Entry Door', '72" 15-lite Steel Entry Door (22 gauge)', 1450]]

steel_doors.each do |(old, new_name, price)|
  r = Component.find_by_name(old).update(name: new_name, small_price: price) rescue false
  puts r
end; nil
