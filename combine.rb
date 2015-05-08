require 'json'
require 'csv'

puts "Parsing journeys and locations..."
journeys = JSON.parse(File.read("export/journeys.json"))
locations = JSON.parse(File.read("export/locations.json")).to_a

# prepare hash of stations that need to be merged
$custom_matches = {}
custom_matches_csv = CSV.foreach("data/custom_matches.csv", {headers: true, col_sep: ';'}) do |stn|
	puts "The station #{stn['from_journeys']} is going to be matched with #{stn['from_locations']}..."
	$custom_matches[stn['from_journeys']] = stn['from_locations']
end

# start the name matching
matches = {};
journeys.each_with_index do |j,ji|
	locations.each_with_index do |l, li|
		jname = j["name"]
		lname = l[0]
		# check if station is one of the custom matches
		if $custom_matches[jname] then
			if $custom_matches[jname] == lname then
				matches[ji] = li
				next
			end
		end

		# or apply the automatic matching algorithm
		jtemp = jname.dup
		ltemp = lname.dup
		
		jtemp.slice!("DLR")
		jtemp.slice!("Station")
		jtemp.strip!
		jtemp.downcase!
		jtemp.gsub!(/\W+/i, '')

		ltemp.slice!("DLR")
		ltemp.slice!("Station")
		ltemp.strip!
		ltemp.downcase!
		ltemp.gsub!(/\W+/i, '')

		if (jtemp == ltemp) then
			matches[ji] = li
		end
	end
end

File.open('export/matches.txt', 'w') do |f|

	matches.each do |key, value|
		puts "#{journeys[key]["name"]} => #{locations[value][0]}"

		# MAKE THE BIG MERGE
		journeys[key]["name"] = locations[value][0]
		journeys[key]["coordinates"] = locations[value][1]
	end
	
	f.puts "All: #{matches.count}"
	puts "All: #{matches.count}"
end

File.open('export/data.json', 'w') do |f|
	f.puts journeys
end