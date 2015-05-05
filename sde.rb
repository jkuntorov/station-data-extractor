require 'csv'
require 'json'

csv_path = 'data/Nov09JnyExample.csv'
# csv_path = 'data/Nov09JnyBigExample.csv'
# csv_path = 'data/Nov09JnyExport.csv'

# open the csv
csv = CSV.read(csv_path, {headers: true})

# define function to handle journey data insertion
def insert_journey(station, day, time) 
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
		stn[:data][day] = Array.new(24)
	end

	# create time if it doesn't exist
	# start time for start station !!!
	if stn[:data][day][time].nil?
		stn[:data][day][time] = {in: 0, out: 0}
	end

	# insert the actual data for the journey
	stn[:data][day][time][:in] += 1
end

# iterate through the csv and build up the data
$stations = [];
csv.each do |r|
	# collect all the necessary data in temp vars
	transport_type = r["SubSystem"]
	day = r["daytype"]
	start_stn = r["StartStn"]
	start_time = r["EntTimeHHMM"][0..1].to_i
	exit_stn = r["EndStation"]
	exit_time = r["EXTimeHHMM"][0..1].to_i

	# do some validations on the data
	next unless transport_type.include? "LUL"

	insert_journey(start_stn, day, start_time)
	insert_journey(exit_stn, day, exit_time)

end

# convert data to json
json_dump = $stations.to_json

# write json to file
File.open('file_json_complete.json', 'w') do |f|
  f.puts json_dump
end

# output to console
puts json_dump