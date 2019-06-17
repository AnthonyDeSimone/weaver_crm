namespace :sidewall_height do
  task :add => :environment do
    CSV.foreach("Barns CSV 2016.csv", {:headers => true}) do |row|
      s = Style.find_by!(name: row['Style'])

      k = StyleKey.find_by!(style: s,
                            width: row['Width'], 
                            length: row['Length'],
                            feature: row['Feature']).update(starting_sidewall_height: row['Wall Height'])
    end
  end
end
