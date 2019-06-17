PricingUpdater.update("pavilion_prices_2019.csv")

style = Style.where(pavillion: true).first

OptionFinder.find_component(style: style, name: "Roof Pitch").update(small_price: 1.2)
OptionFinder.find_component(style: style, name: "Brackets").order_id
OptionFinder.find_component(style: style, name: "Top of Beam Height").update(small_price: 18)

OptionFinder.find_component_option(style: style, name: "Windowpane Style").update(small_price: 340)
OptionFinder.find_component_option(style: style, name: "Traditional Style").update(small_price: 340)
OptionFinder.find_component(style: style, name: "Copper Colored Metal Roof").update(small_price: 100)
OptionFinder.find_component_option(style: style, name: "Metal Roof").update(small_price: 2.03, name: "Metal Roof (Legacy Panel)")

StyleKey.joins(:style).where("styles.pavillion": true, feature: "Premier").update_all(feature: "Solid Pine")  


ComponentOption.find_by_name("Metal Roof (Legacy Panel)").update(name: "Metal Roof")