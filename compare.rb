require 'json'
require 'csv'

journeys_json = JSON.parse(File.read("export/journeys.json"))
locations_json = JSON.parse(File.read("export/locations.json"))

journeys = []
locations = []

puts "Parsing journeys..."
journeys_json.each do |j|
	journeys << j["name"]
end

puts "Parsing locations..."
locations_json.each do |j|
	locations <<  j[0]
end

puts "Sorting arrays..."
journeys.sort!
locations.sort!

puts "Starting to write in a file..."
File.open('export/comparison.txt', 'w') do |f|
  f.puts "JOURNEYS"
  f.puts journeys
  f.puts "\n"
  f.puts "LOCATIONS"
  f.puts locations
end

# prepare hash of stations that need to be merged
$custom_matches = {}
custom_matches_csv = CSV.foreach("data/custom_matches.csv", {headers: true, col_sep: ';'}) do |stn|
	puts "The station #{stn['from_journeys']} is going to be matched with #{stn['from_locations']}..."
	$custom_matches[stn['from_journeys']] = stn['from_locations']
end


matches = {};

journeys.each_with_index do |j,ji|
	locations.each_with_index do |l, li|
		# check if start station needs to be merged
		if $custom_matches[j] then
			if $custom_matches[j] == l then
				matches[ji] = li
				next
			end
		end

		jtemp = j.dup
		ltemp = l.dup
		
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

puts "\nMatches:"
# puts matches

puts "Starting to write in a file..."
File.open('export/matches.txt', 'w') do |f|

	matches.each do |key, value|
		f.puts "#{journeys[key]} => #{locations[value]}"
		# puts "#{journeys[key]} => #{locations[value]}"
	end
	
	f.puts "All: #{matches.count}"
	puts "All: #{matches.count}"
end



puts "Done."