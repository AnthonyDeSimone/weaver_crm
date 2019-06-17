# No Eco Pro for any of the new barns!


# Copy components to large barns

StyleSizeFinish.where(size: "large", feature: ["Premier", "Deluxe", "Vinyl"]).each do |ssf| 
  small_ssf = StyleSizeFinish.find_by(size: "small", feature: ssf.read_attribute(:feature))
  ssf.components = small_ssf.components


  price_update_components = {"Higher Sidewall for Solid Pine Buildings": 6.75, 
                              "Higher Sidewall for Vinyl Buildings": 8.0, 
                              "Higher Sidewall for Duratemp Buildings": 6.25,
                              "Roof Pitch": 0.85}

  price_update_components.each_pair do |name, price|
    ssf.key_component_pairs.joins(:component).where("components.name": name).delete_all
    new_component = Component.find_by_name(name).dup
    new_component.update(small_price: price)
    ssf.components << new_component
  end

  # Metal Roof for Dutch
  old_component = Component.find_by_name("Roof")
  new_component = old_component.dup
  new_component.save!
  new_component.component_options.create(name: "15# Felt Paper ", small_price: 0.3)
  new_component.component_options.create(name: "Metal Roof", small_price: 1.3)
  new_component.component_options.create(name: "Metal Roof on Dutch", small_price: 3.3)
  new_component.component_options.create(name: "None", small_price: 0)
  ssf.key_component_pairs.joins(:component).where("components.id": 867).delete_all
  ssf.components << new_component

  components_to_remove = ["Ramp", "Site Prep w/Patio Blocks up to 8\" high", "Drop Slope Height", "Carry Charge", 
                          "Waste Removal", "Runner Upgrade", "4x4 Runner", "4x6 Runner"]

  components_to_remove.each do |name|
    ssf.key_component_pairs.joins(:component).where("components.name": name).delete_all
  end

  ssf.key_component_pairs.joins(:component).where("components.name": "Weathervane").delete_all
  new_component = Component.find_by_name("Weathervane").dup
  weathervane_options = {"Small - Rooster": 170, "Small - Eagle": 250, "Small - Horse": 170, 
                        "Small - Labrador Retriever": 170, "Large - Rooster": 300, "Large - Eagle": 360,
                      "Large - Horse": 340, "Large - Labrador Retriever": 450}
  weathervane_options.each_pair do |name, price|
    new_component.component_options << ComponentOption.create(name: name, small_price: price)
  end
  ssf.components << new_component

  # New Random components
  c = ComponentSubcategory.find_by_name("Foundation").components.create(name: "Post Perimeter Foundation", pricing_type: "each", form_type: "text", requires_quantity: true)
  ssf.components << c

  lofts = ['Loft - 2 x 8 with 5/8" plywood', 'Loft - 2 x 10 with 3/4" Plywood', 'Loft - I-Joists with 3/4" Plywood']

  lofts.each do |name|
    c = ComponentSubcategory.find_by_name("Lofts").components.create(name: name, pricing_type: "each", form_type: "text", requires_quantity: true)
    ssf.components << c
  end



  c1 = Component.find_by_name("Steel Entry Door").dup

  ssf.key_component_pairs.joins(:component).where("components.name": "Steel Entry Door").delete_all
  c1.save
    
  c1.component_options = [ComponentOption.create(name: "36\" 9-lite Economy Steel Entry Door", small_price: 655), ComponentOption.create(name: "No Door", small_price: 0)]

  ssf.components << c1
  
end



###################################################
# ADD CLASSIC                                    ##
###################################################
s = Style.create(name: "The Classic", do_not_compare: true, large_garage: true)

PricingUpdater.update("barn_prices_classic.csv")

StyleKey.where(feature: "Duratemp").update_all(feature: "Deluxe")
StyleKey.where(feature: "Solid Pine").update_all(feature: "Premier")


StyleSizeFinish.find_by(feature: "Premier", size: "large").style_keys << StyleKey.where(style: s, feature: "Premier")
StyleSizeFinish.find_by(feature: "Deluxe", size: "large").style_keys << StyleKey.where(style: s, feature: "Deluxe")
StyleSizeFinish.find_by(feature: "Vinyl", size: "large").style_keys << StyleKey.where(style: s, feature: "Vinyl")



c = Component.where(name: "Steel Entry Door").last
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name:"36\" 9-lite Economy Steel Entry Door").last)
c = Component.find_by_name("Overhead Door")
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name: "9'W x 7'H Overhead Door - Non-Insulated").last)

s.update(name: "The Classic Garage")

###################################################
# ADD DUTCH                                      ##
###################################################
s = Style.create(name: "Dutch", do_not_compare: true, large_garage: true)

PricingUpdater.update("barn_prices_dutch.csv")

StyleKey.where(feature: "Duratemp").update_all(feature: "Deluxe")
StyleKey.where(feature: "Solid Pine").update_all(feature: "Premier")


StyleSizeFinish.find_by(feature: "Premier", size: "large").style_keys << StyleKey.where(style: s, feature: "Premier")
StyleSizeFinish.find_by(feature: "Deluxe", size: "large").style_keys << StyleKey.where(style: s, feature: "Deluxe")
StyleSizeFinish.find_by(feature: "Vinyl", size: "large").style_keys << StyleKey.where(style: s, feature: "Vinyl")


c = Component.where(name: "Steel Entry Door").last
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name:"36\" 9-lite Economy Steel Entry Door").last)
c = Component.find_by_name("Overhead Door")
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name: "9'W x 7'H Overhead Door - Non-Insulated").last)

s.update(name: "Dutch Garage")

###################################################
# ADD ROCKPORT                                   ##
###################################################
s = Style.create(name: "Rockport", do_not_compare: true, large_garage: true)

PricingUpdater.update("barn_prices_rockport.csv")

StyleKey.where(feature: "Duratemp").update_all(feature: "Deluxe")
StyleKey.where(feature: "Solid Pine").update_all(feature: "Premier")


StyleSizeFinish.find_by(feature: "Premier", size: "large").style_keys << StyleKey.where(style: s, feature: "Premier")
StyleSizeFinish.find_by(feature: "Deluxe", size: "large").style_keys << StyleKey.where(style: s, feature: "Deluxe")
StyleSizeFinish.find_by(feature: "Vinyl", size: "large").style_keys << StyleKey.where(style: s, feature: "Vinyl")


c = Component.where(name: "Steel Entry Door").last
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name:"36\" 9-lite Economy Steel Entry Door").last)
c = Component.find_by_name("Overhead Door")
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name: "9'W x 7'H Overhead Door - Non-Insulated").last)

s.update(name: "Rockport Garage")

###################################################
# ADD WILLOW CREEK                                   ##
###################################################
s = Style.create(name: "Willow Creek", do_not_compare: true, large_garage: true)

PricingUpdater.update("barn_prices_willow_creek.csv")

StyleKey.where(feature: "Duratemp").update_all(feature: "Deluxe")
StyleKey.where(feature: "Solid Pine").update_all(feature: "Premier")


StyleSizeFinish.find_by(feature: "Premier", size: "large").style_keys << StyleKey.where(style: s, feature: "Premier")
StyleSizeFinish.find_by(feature: "Deluxe", size: "large").style_keys << StyleKey.where(style: s, feature: "Deluxe")
StyleSizeFinish.find_by(feature: "Vinyl", size: "large").style_keys << StyleKey.where(style: s, feature: "Vinyl")

c = Component.where(name: "Steel Entry Door").last
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name:"36\" 9-lite Economy Steel Entry Door").last)
c = Component.find_by_name("Overhead Door")
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name: "9'W x 7'H Overhead Door - Non-Insulated").last)

s.update(name: "Willow Creek Garage")


# KLUDGES
ComponentOption.where(name: "36\" 9-lite Economy Steel Entry Door").order(:created_at).last.update(image_data: Component.find(932).image_data)
#ComponentSubcategory.find_by_name("Steel Entry Door").components.where("name ilike '36\"%'").update_all(image_url: image)


# Default Options Fix
# Default door fix

Style.where(large_garage: true).each do |s|
  [2115, 2101].each do |co_id|
    co = ComponentOption.find(co_id)
    
    s.default_options << DefaultOption.create(component: co.component, component_option: co)
  end
end