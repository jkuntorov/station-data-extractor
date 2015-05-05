require 'open-uri'
require 'nokogiri'
require 'csv'
require 'json'

# fetch the station location data from TfL and create an XML document
url = 'http://www.tfl.gov.uk/cdn/static/cms/documents/stations.kml'
doc = Nokogiri::XML(open(url))
puts "Document opened..."

# define data object
stations = {}

doc.css('Placemark').each do |placemark|
	# extract raw name & coordinate strings for the current station
	name = placemark.css('name')
	coordinates = placemark.at_css('coordinates')

	# if the data is ok (no NULL values)
	unless name.nil? || coordinates.nil?
		# trim out excess whitespace from the name string
		name = name.text.strip!
		puts "Getting coordinates for #{name}..."

		# trim out excess whitespace from the coordinates string
		coordinates = coordinates.text.strip!.to_s

		# split the coordinates string into separate variables
		(lon,lat,elevation) = coordinates.split(',')

		# insert data about the station in the data object
		stations[name] = {lat: lat, lon: lon}
	end
end

# insert information about missing stations
missing_csv = CSV.foreach("data/missing_stations.csv", {headers: true}) do |r|
	stations[r['name']] = {lat: r['lat'], lon: r['lon']}
	puts "Adding additional information about #{r['name']}..."
end

# remove clashing stations (old East London Line which is still listed as Tube)
excess_csv = CSV.foreach("data/excess_stations_from_locations.csv", {headers: false}) do |stn|
	if ( stations.reject! {|key,value| key == stn[0]} ) then
		puts "Deleting information about #{stn[0]} (excess station)..."
	end
end

# convert data to json
puts "Starting conversion to JSON..."
json_dump = stations.to_json

# write json to file
puts "Saving JSON file..."
File.open('export/locations.json', 'w') do |f|
	f.puts json_dump
end

puts "JSON has been exported."