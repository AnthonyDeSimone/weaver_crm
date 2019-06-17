namespace :component_pricing do
  task :update => :environment do
    CSV.foreach('form.csv', {:headers => true}) do |row|
      next if row['Field'] == 'Custom Field'
      next if row['Field'] == 'Paint Color'
      next if row['Field'] == 'Stain Color'
      includes_small = row['Applicable'].include?('small')
      includes_large = row['Applicable'].include?('large')
      puts row['Section'],  row['Subsection'], row['Field']
      
      section = ComponentCategory.find_by!(name: row['Section'])
      subsection = ComponentSubcategory.find_by!(name: row['Subsection'], component_category: section)

      field = Component.find_by!(component_subcategory: subsection, name: row['Field'])

      if(row['Type'] == 'numeric' || row['Type'] == 'text'|| row['Type'] == 'checkbox' || row['Type'] == 'check_price' || row['Type'] == 'check_length')
        puts "Old price: #{field.small_price}, New price: #{row['Price'].andand.gsub(/$|,/, '').to_f }"
        
        field.small_price = row['Price'].andand.gsub(/$|,/, '').to_f  
        field.large_price = (row['Price_large'] || row['Price']).andand.gsub(/$|,/, '').to_f  
        field.save
      elsif((row['Type'] == 'select' || row['Type'] == 'radio' || row['Type'] == 'select_price') && !row['Option'].nil? && !row['Option'].empty?)
        option = field.component_options.find_by!(name: row['Option'])
        
        puts "Old price: #{option.small_price}, New price: #{row['Price'].andand.gsub(/$|,/, '').to_f }"        
        option.update(small_price: row['Price'].andand.gsub(/$|,/, '').to_f, 
                       large_price: (row['Price_large'] || row['Price']).andand.gsub(/$|,/, '').to_f)
      end
    end
  end
end
