task :export_orders_to_dropbox => :environment do
  puts "Exporting orders to dropbox..."
  SalesOrder.export_to_dropbox
  puts "done"
end
