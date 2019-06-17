###################################################
# ADD NEW DEFAULT DOORS                          ##
###################################################

c1 = Component.find_by_name("Single Door").dup
c1.update(name: "Steel Entry Door")
c1.component_options = [ComponentOption.create(name: "36\" 9-lite Economy Steel Entry Door", small_price: 455), ComponentOption.create(name: "No Door", small_price: 0)]

c2 = Component.find_by_name("Steel Entry Door").dup
c2.update(name: "Overhead Door")
image = Component.find_by_name("9'W x 7'H Overhead Door").image_url
c2.component_options = [ComponentOption.create(name: "9'W x 7'H Overhead Door - Non-Insulated", small_price: 995, image_url: image), ComponentOption.create(name: "No Door", small_price: 0)]

StyleSizeFinish.joins(style_keys: :style).where(feature: ["Premier", "Deluxe", "Vinyl", "Eco Pro"]).each do |ssf|  
  ssf.components << c1
  ssf.components << c2
end


###################################################
# ADD STUDIOS                                    ##
###################################################

# Add Studio Style
s = Style.create(name: "Studio")

PricingUpdater.update("barn_prices_studio.csv")

#Update this dumb thing
StyleKey.where(feature: "Duratemp").update_all(feature: "Deluxe")
StyleKey.where(feature: "Solid Pine").update_all(feature: "Premier")



StyleSizeFinish.find_by(feature: "Premier").style_keys << StyleKey.where(style: s, feature: "Premier")
StyleSizeFinish.find_by(feature: "Deluxe").style_keys << StyleKey.where(style: s, feature: "Deluxe")
StyleSizeFinish.find_by(feature: "Vinyl").style_keys << StyleKey.where(style: s, feature: "Vinyl")
StyleSizeFinish.find_by(feature: "Eco Pro").style_keys << StyleKey.where(style: s, feature: "Eco Pro")


#Add default options
s.default_options << DefaultOption.create(component: Component.find_by_name("Roof"), component_option: ComponentOption.find_by_name("Metal Roof"))
#c = Component.find_by_name("Steel Entry Door")
#s.default_options << DefaultOption.create(component: c, component_option: c.component_options.find_by_name("36\" 6-Panel Steel Entry Door"))




###################################################
# ADD GABLE GARAGES                              ##
###################################################

s = Style.create(name: "Gable Garage")

PricingUpdater.update("barn_prices_gable_garage.csv")

#Update this dumb thing
StyleKey.where(feature: "Duratemp", style: s).update_all(feature: "Deluxe")
StyleKey.where(feature: "Solid Pine", style: s).update_all(feature: "Premier")



StyleSizeFinish.find_by(feature: "Premier").style_keys << StyleKey.where(style: s, feature: "Premier")
StyleSizeFinish.find_by(feature: "Deluxe").style_keys << StyleKey.where(style: s, feature: "Deluxe")
StyleSizeFinish.find_by(feature: "Vinyl").style_keys << StyleKey.where(style: s, feature: "Vinyl")
StyleSizeFinish.find_by(feature: "Eco Pro").style_keys << StyleKey.where(style: s, feature: "Eco Pro")


##############################
GGO BACK TO TOP
##########################


# Add default options
# Also need to be able to add a door credit for the second option
#s.default_options << DefaultOption.create(component: Component.find_by_name("36\" 9-lite Economy Steel Entry Door"))
#s.default_options << DefaultOption.create(component: Component.find_by_name("9'W x 7'H Overhead Door"), component_option: ComponentOption.find_by_name("9'W x 7'H Overhead Door - Non-Insulated"))



c = Component.find_by_name("Steel Entry Door")
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name:"36\" 9-lite Economy Steel Entry Door").last)
c = Component.find_by_name("Overhead Door")
s.default_options << DefaultOption.create(component: c, component_option: c.component_options.where(name: "9'W x 7'H Overhead Door - Non-Insulated").last)


###################################################
# ADD PAVILLIONS                                ##
###################################################

  s1 = Style.find_by(name: "Timber Ridge", pavillion: true)  
  s2 = Style.find_by(name: "Bradford", pavillion: true)
  s3 = Style.find_by(name: "Dublin", pavillion: true)

  PricingUpdater.update("barn_prices_pavillion.csv")

StyleKey.where(style: [s1,s2,s3]).update_all(minimum_roof_pitch: 5)

## Add keys
StyleSizeFinish.create(feature: "Solid Pine", size: "small")
StyleSizeFinish.create(feature: "Solid Cedar", size: "small")
StyleSizeFinish.create(feature: "Pavillion Vinyl", size: "small")

StyleSizeFinish.find_by(feature: "Solid Pine").style_keys << StyleKey.where(style: s1, feature: "Solid Pine")
StyleSizeFinish.find_by(feature: "Solid Pine").style_keys << StyleKey.where(style: s2, feature: "Solid Pine")

StyleSizeFinish.find_by(feature: "Solid Cedar").style_keys << StyleKey.where(style: s1, feature: "Solid Cedar")
StyleSizeFinish.find_by(feature: "Solid Cedar").style_keys << StyleKey.where(style: s2, feature: "Solid Cedar")


StyleSizeFinish.find_by(feature: "Pavillion Vinyl").style_keys << StyleKey.where(style: s3, feature: "Pavillion Vinyl")


###################################################
# PAVILLION COMPONENTS                           ##
###################################################

beam = Component.find_by_name("Roof Pitch").dup
beam.update(name: "Top of Beam Height", small_price: 17, pricing_type: "each")

anchoring = Component.find_by_name("Top of Beam Height").dup

anchoring.update(name: "Anchoring", form_type: "radio")
anchoring.component_options = [ComponentOption.create(name: "Anchored to level deck or concrete"), ComponentOption.create(name: "Duracolumns"), ComponentOption.create(name: "Other Anchoring")]

anchoring.component_subcategory = ComponentSubcategory.create(name: "Anchoring", component_category: ComponentCategory.find_by_name("Foundation"))
anchoring.save

bracket1 = Component.find_by_name("Top of Beam Height").dup
bracket1.update(name: "Brackets", form_type: "radio")
bracket1.component_options = [ComponentOption.create(name: "Straight Brackets"), ComponentOption.create(name: "Curved Brackets")]

bracket2 = Component.find_by_name("Top of Beam Height").dup
bracket2.update(name: "Brackets", form_type: "radio")

bracket2.component_options = [ComponentOption.create(name: "Standard Brackets", small_price: 0), ComponentOption.create(name: "Arched Brackets", small_price: 0), ComponentOption.create(name: "Curved Brackets", small_price: 0), ComponentOption.create(name: "Harbor Brackets", small_price: 0)]


StyleSizeFinish.joins(style_keys: :style).where(styles: {pavillion: true}).where(feature: ["Solid Pine", "Solid Cedar"]).each do |ssf| 
  ssf.components << bracket1
end

StyleSizeFinish.joins(style_keys: :style).where(styles: {pavillion: true}).where(feature: ["Pavillion Vinyl"]).each do |ssf| 
  ssf.components << bracket2
end

custom1 = Component.joins(component_subcategory: :component_category).where(components: {name: "Custom Field"}, component_categories: {name: "Structural"}).first
custom2 = Component.joins(component_subcategory: :component_category).where(components: {name: "Custom Field"}, component_categories: {name: "Roof"}).first
custom3 = Component.joins(component_subcategory: :component_category).where(components: {name: "Custom Field"}, component_categories: {name: "Foundation"}).first.dup
custom4 = Component.joins(component_subcategory: :component_category).where(components: {name: "Custom Field"}, component_categories: {name: "Paint & Stain"}).first
custom3.component_subcategory = ComponentSubcategory.new(name: "Custom", component_category: ComponentCategory.find_by_name("Foundation"))
custom3.save

StyleSizeFinish.joins(style_keys: :style).where(styles: {pavillion: true}).where(feature: ["Pavillion Vinyl", "Solid Pine", "Solid Cedar"]).each do |ssf|  
  ssf.components << Component.find_by_name("Roof Pitch")
  ssf.components << beam
  ssf.components << anchoring
  ssf.components << Component.find_by_name("Roof")
  ssf.components << Component.find_by_name("Shingles")
  ssf.components << Component.find_by_name("Shingle Color")
  ssf.components << Component.find_by_name("Drip Edge Color")
  ssf.components << Component.find_by_name("Metal Roof Color")
  
  ssf.components << custom1
  ssf.components << custom2
  ssf.components << custom3
  ssf.components << custom4
  
  ssf.components << Component.joins(component_subcategory: :component_category).where("component_categories.name": "Cupolas")
  
  #Paint/Stain
  ssf.components << Component.find(873)
  ssf.components << Component.find(878)
end


#Add default options
s1.default_options << DefaultOption.create(component: bracket1, component_option: bracket1.component_options.find_by_name("Curved Brackets"))
s2.default_options << DefaultOption.create(component: bracket1, component_option: bracket1.component_options.find_by_name("Curved Brackets"))
s3.default_options << DefaultOption.create(component: bracket2, component_option: bracket2.component_options.find_by_name("Standard Brackets"))

s1.default_options << DefaultOption.create(component: Component.find_by_name("Anchoring"), component_option: ComponentOption.find_by_name("Anchored to level deck or concrete"))
s2.default_options << DefaultOption.create(component: Component.find_by_name("Anchoring"), component_option: ComponentOption.find_by_name("Anchored to level deck or concrete"))
s3.default_options << DefaultOption.create(component: Component.find_by_name("Anchoring"), component_option: ComponentOption.find_by_name("Anchored to level deck or concrete"))


 
stain_subcat = Component.find_by_name("Body Color").component_subcategory.component_category.component_subcategories.find_by_name("Stain")
paint_subcat = Component.find_by_name("Body Color").component_subcategory.component_category.component_subcategories.find_by_name("Paint")

paint_color = Component.find_by_name("Body Color").dup
paint_color.update(name: "Paint Color", component_subcategory: paint_subcat)


options = "Almond
Avocado
Barn White
Black
Bronze Paint
Brown
Buckskin
Charcoal
Clay
Cream
Dark Gray
Jamestown Red
Jasper Gray
Mountain Red
Navajo White
Non Stock Color
Pinnacle Red
Shale
Spice
Steel Gray
Timber
Wild Grasses
Woodland Green".split("\n")


options.each {|o| paint_color.component_options << ComponentOption.create(name: o)}


timber_color = Component.find_by_name("Body Color").dup

timber_color = Component.find_by_name("Body Color").dup
timber_color.update(name: "Timber Color", component_subcategory: stain_subcat)
options = "bark
bronze
butternut
caramel
chestnut brown
driftwood
ebony
mahogany
natural
pecan
pioneer brown
smoke".split("\n")

options.each {|o| timber_color.component_options << ComponentOption.create(name: o)}


ceiling_color = Component.find_by_name("Timber Color").dup
ceiling_color.update(name: "Ceiling Color")

options = "bark
bronze
butternut
caramel
chestnut brown
driftwood
ebony
mahogany
natural
pecan
pioneer brown
smoke".split("\n")

options.each {|o| ceiling_color.component_options << ComponentOption.create(name: o)}

StyleSizeFinish.where(feature: ["Solid Pine", "Solid Cedar"]).each do |ssf| 
  ssf.components << timber_color
  ssf.components << ceiling_color
end 

vinyl_color = Component.find_by_name("Ceiling Color").dup
vinyl_color.update(name: "Vinyl Color")
vinyl_color.component_options << ComponentOption.create(name: "white")

ceiling_color = Component.find_by_name("Vinyl Color").dup
ceiling_color.update(name: "Ceiling Color", component_subcategory: stain_subcat)
ceiling_color.component_options = [ComponentOption.create(name: "bark"), ComponentOption.create(name: "natural"), ComponentOption.create(name: "smoke")]

StyleSizeFinish.where(feature: ["Pavillion Vinyl"]).each do |ssf| 
  ssf.components << vinyl_color
  ssf.components << ceiling_color
end 

StyleSizeFinish.where(feature: ["Pavillion Vinyl","Solid Pine", "Solid Cedar"]).each do |ssf| 
  ssf.components << paint_color
end

Component.where(name: "4'").update_all(width: 4, height: 3)
Component.where(name: "5'").update_all(width: 5, height: 3)
Component.where(name: "6'").update_all(width: 6, height: 3)
Component.where(name: "7'").update_all(width: 7, height: 3)
Component.where(name: "2' x 2' Single Hung with screen & grids").first.update(width: 2, height: 1)

image = Component.where(name: "36\"").first.image_url 
ComponentOption.where(name: "36\" 9-lite Economy Steel Entry Door").update_all(image_url: image)
ComponentSubcategory.find_by_name("Steel Entry Door").components.where("name ilike '36\"%'").update_all(image_url: image)
