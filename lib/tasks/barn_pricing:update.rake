namespace :barn_pricing do
  task :update => :environment do
    CSV.foreach("barn_prices_gable_garage.csv", {:headers => true}) do |row|
      zone_prices   = {}

      1.upto(7) do |zone|
        current = "zone_#{zone}".to_sym

        zone_prices[current] = {}
        zone_prices[current][:prebuilt] = { :base           => row["Z#{zone} Prebuilt"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_paint => row['Duratemp Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :eco_pro_paint  => row['Duratemp Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :pine_paint     => row['Pine Painting - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_stain => row['Duratemp Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,
                                            :eco_pro_stain  => row['Duratemp Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,
                                            :pine_stain     => row['Pine Staining - Option'].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f}

        zone_prices[current][:AOS]      = { :base           => row["Z#{zone} AOS"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_paint => row["Duratemp Painting - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :eco_pro_paint  => row["Duratemp Painting - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :pine_paint     => row["Pine Painting - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f, 
                                            :duratemp_stain => row["Duratemp Staining - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,                                     
                                            :eco_pro_stain  => row["Duratemp Staining - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f,                                     
                                            :pine_stain     => row["Pine Staining - Option"].andand.gsub(/\$|,/, '').nil_if {|p| p == 'N/A'}.to_f}                                        
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
      
      puts row['Wall Height']

      if(k.feature.nil?)
        k.update(feature: row['Feature'], display_feature: row['Feature'])
      end
     # p k.zone_prices
    end
  end
end
