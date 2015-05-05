require 'csv'
require 'json'

# paths of csv files
# csv_path = 'data/Nov09JnyExample.csv'			# 20 records
# csv_path = 'data/Nov09JnyMediumExample.csv'	# 100 thousand records
# csv_path = 'data/Nov09JnyBigExample.csv'		# 360 thousand records
csv_path = 'data/Nov09JnyExport.csv'			# 2.6 million records - the real thing

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

	# do some validations on the data
	next unless transport_type.include? "LUL"
	next if start_stn == "Unstarted"
	next if exit_stn == "Unfinished"

	puts "#{$.} Journey on #{day} from #{start_stn} to #{exit_stn} (#{start_time} - #{exit_time})."

	insert_journey(start_stn, day, start_time, :in)
	insert_journey(exit_stn, day, exit_time, :out)

end

# convert data to json
puts "Starting conversion to JSON..."
json_dump = $stations.to_json

# write json to file
puts "Saving JSON file..."
File.open('export/stations.json', 'w') do |f|
  f.puts json_dump
end

puts "JSON has been exported."