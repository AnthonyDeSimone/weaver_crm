task :export_orders_to_fishbowl => :environment do
  settings = Setting.first
  
  if(settings.fishbowl_ip != "")
    puts "Exporting orders to fishbowl..."
    SalesOrder.where(in_fishbowl: false, issued: true).where.not(customer: nil).each {|o| o.export_to_fishbowl}
  end
  
  puts "done"
end
