require 'csv'
require 'json'

# paths of csv files
# csv_path = 'data/journeys/Nov09JnyExample.csv'		# 20 records
# csv_path = 'data/journeys/Nov09JnyMediumExample.csv'	# 100 thousand records
# csv_path = 'data/journeys/Nov09JnyBigExample.csv'		# 360 thousand records
csv_path = 'data/journeys/Nov09JnyExport.csv'			# 2.6 million records - the real thing

# define function to handle journey data insertion
def insert_journey(station, day, time, direction) 

	# create station if it doesn't exist
	unless $stations.any? { |el| el[:name] == station } then
		$stations << {name: station, data: {}}
		puts "Created #{station}"
	end

	# prepare the station object
	index = $stations.find_index {|item| item[:name] == station}
	stn = $stations[index]

	# start inserting details about the journey
	
	# create day if it doesn't exist
	unless stn[:data].has_key? day then
		stn[:data][day] = {}
	end

	# create time if it doesn't exist
	# start time for start station !!!
	unless stn[:data][day].has_key? time then
		stn[:data][day][time] = {in: 0, out: 0, all: 0}
	end

	# insert the actual data for the journey
	stn[:data][day][time][:all] += 1
	stn[:data][day][time][direction] += 1

end

# prepare hash of stations that need to be merged
$duplicates = {}
excess_csv = CSV.foreach("data/merge_stations.csv", {headers: true}) do |stn|
	puts "The station #{stn['excess_station']} will be merged into #{stn['merge_into']}..."
	$duplicates[stn['excess_station']] = stn['merge_into']
end

# define an empty data object
$stations = [];

# open the csv and iterate through the records
csv = CSV.foreach(csv_path, {headers: true}) do |r|

	# collect all the necessary data in temp vars
	transport_type = r["SubSystem"]
	day = r["daytype"]
	start_stn = r["StartStn"]
	start_time = r["EntTimeHHMM"][0..1]
	exit_stn = r["EndStation"]
	exit_time = r["EXTimeHHMM"][0..1]

	# check if start station needs to be merged
	if $duplicates[start_stn] then
		start_stn = $duplicates[start_stn]
	end

	# check if end station needs to be merged
	if $duplicates[exit_stn] then
		exit_stn = $duplicates[exit_stn]
	end

	# do some validations on the data,
	# if not valid - skip this journey
	next unless transport_type.include? "LUL"
	next if start_stn == "Unstarted"
	next if exit_stn == "Unfinished"
	next if start_stn == "Not Applicable" || exit_stn == "Not Applicable"

	# insert journeys
	insert_journey(start_stn, day, start_time, :in)
	insert_journey(exit_stn, day, exit_time, :out)

	# show it's alive
	puts "#{$.} Journey on #{day} from #{start_stn} to #{exit_stn} (#{start_time} - #{exit_time})."

end

# remove excess stations (National Rail, Overground, etc)
excess_csv = CSV.foreach("data/excess_stations_from_journeys.csv", {headers: false}) do |stn|
	if ( $stations.reject! {|element| element[:name] == stn[0]} ) then
		puts "Deleting information about #{stn[0]} (excess station)..."
	end
end

# convert data to json
puts "Starting conversion to JSON..."
json_dump = $stations.to_json

# write json to file
puts "Saving JSON file..."
File.open('export/journeys.json', 'w') do |f|
	f.puts json_dump
end

puts "JSON has been exported."