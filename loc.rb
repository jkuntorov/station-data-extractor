require 'open-uri'
require 'nokogiri'
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

# convert data to json
puts "Starting conversion to JSON..."
json_dump = stations.to_json

# write json to file
puts "Saving JSON file..."
File.open('export/loc.json', 'w') do |f|
	f.puts json_dump
end

puts "JSON has been exported."