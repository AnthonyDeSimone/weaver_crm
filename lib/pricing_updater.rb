module PricingUpdater
  def self.update(filename)
    CSV.foreach(filename, {:headers => true}) do |row|
	puts row.inspect
      zone_prices   = {}

      1.upto(7) do |zone|
        current = "zone_#{zone}".to_sym

        zone_prices[current] = {}
        zone_prices[current][:prebuilt] = { :base           => row["Z#{zone} Prebuilt"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :color          => row["Color - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_paint => row['Duratemp Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :eco_pro_paint  => row['Duratemp Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :pine_paint     => row['Pine Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_stain => row['Duratemp Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,
                                            :eco_pro_stain  => row['Duratemp Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,
                                            :pine_stain     => row['Pine Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,
                                            :duracolumn     => row["Z#{zone} Duracolumn"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f
                                          }

        zone_prices[current][:AOS]      = { :base           => row["Z#{zone} AOS"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :color          => row["Color - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_paint => row["Duratemp Painting - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :eco_pro_paint  => row["Duratemp Painting - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :pine_paint     => row["Pine Painting - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_stain => row["Duratemp Staining - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,                                     
                                            :eco_pro_stain  => row["Duratemp Staining - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,                                     
                                            :pine_stain     => row["Pine Staining - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,
                                            :duracolumn     => row["Z#{zone} Duracolumn"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f                                        
                                        }
      end

      ln_ft = (row['Width'].to_i + row['Length'].to_i) * 2

      s = Style.where("name = ? OR display_name = ?", row['Style'], row['Style']).first!

     # p zone_prices
      doors = row.select {|k,v| v == 'Y'}.map(&:first) 
      
      k = StyleKey.where(style: s,
                          width: row['Width'], 
                          length: row['Length'])
                  .where("feature = ? OR display_feature = ?", row['Feature'], row['Feature']).first_or_create!
                  
      k.update( zone_prices: zone_prices.to_json, door_defaults: doors.to_json, starting_roof_pitch: row['Pitch'], 
                starting_sidewall_height: row['Wall Height'], beam_height: row['Beam Height'], post_amount: row['Post Amount'])

      if(k.feature.nil?)
        k.update(feature: row['Feature'], display_feature: row['Feature'])
      end
    end
    
    count = StyleKey.where(sq_feet: nil).count

    StyleKey.where(sq_feet: nil).each do |key|
      key.update(sq_feet: (key.width * key.length), ln_feet: ((key.width * 2) + (2 * key.length)))
    end

    puts "#{count} styles added"    
  end
end
