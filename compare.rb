require 'json'

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

puts "Done."