require 'csv'
devices = CSV.read('devices.csv')

# headers for csv files
testers_keys = ["testerId","firstName","lastName","country","lastLogin"]
devices_keys = ["deviceId","description"]
bugs_keys = ["bugId","deviceId","testerId"]
tester_device_keys = ["testerId","deviceId"]

def save_csv_as_hashes_array(keys, csv_file)
	 CSV.read(csv_file).map {|a| Hash[ keys.zip(a) ]}
end

# save each CVS as array of hashes
testers_array = save_csv_as_hashes_array(testers_keys, 'testers.csv')
bugs_array = save_csv_as_hashes_array(bugs_keys, 'bugs.csv')
devices_array = save_csv_as_hashes_array(devices_keys, 'devices.csv')
tester_device_array = save_csv_as_hashes_array(tester_device_keys, 'tester_device.csv')


# prompt user to enter countries and devices
def get_input()
	puts "Enter countries, separated by commas"
	tester_countries = "GB, US" #gets
	puts "Enter devices, separated by commas"
	device_names = "iPhone 5, Galaxy S3, Galaxy S4" #gets
	#save input as array of arrays, strip empty spaces for each
	[device_names.split(",").map! {|device| device.strip()}, 
		tester_countries.split(",").map! {|tester_country| tester_country.strip()}]
end

# save device_names and tester_countries user queried
device_names, tester_countries = get_input()


# save device_id array from devices user requested
device_ids_query = device_names.map {|device_name| 
					devices_array.select {|device| device["description"] ==  device_name
						}.map {|device|  device["deviceId"]}
					}.flatten


# save tester_ids array  from testers user requested
tester_ids_query = tester_countries.map {|country| 
					testers_array.select {|tester| tester["country"] ==  country
						}.map {|tester|  tester["testerId"]}
					}.flatten


# save all possible combinations of tester_ids and device_ids in array
tester_device_combinations = device_ids_query.product(tester_ids_query).map {|combination| {"testerId"=>combination[0], "deviceId"=>combination[1]}}

testers_using_devices = tester_device_combinations.select{|entry| tester_device_array.include?(entry)}

# count how many times each combination appears in bugs array

def tester_device_in_bugs_count(testerId, deviceId, bugs_array)
	count = bugs_array.select {|bug| bug['deviceId'] == deviceId && bug['testerId'] ==  testerId}.count
	{"testerId" => testerId, "deviceId" => deviceId, "count" => count}

end 

user_bugs = tester_device_combinations.map {|combination|
			#check how many times each combination appears
			tester_device_in_bugs_count(combination["testerId"], combination["deviceId"], bugs_array)}

#check how many bugs each user has, return list in descending order	
user_bugs_sorted = user_bugs.sort_by { |k| -k["count"] }

# agregate bugs count for same users
user_total_count = {}

user_bugs.each {|tester_device| 
	#puts tester_device
	tester_id = tester_device["testerId"]# ("4")
	tester_experience = tester_device["count"] # ("55")
	if user_total_count[tester_id]
		count = user_total_count[tester_id] + tester_experience.to_i
		user_total_count[tester_id] =  count
	else
		user_total_count[tester_id]= tester_experience
	end
}

user_total_count_sorted =  Hash[user_total_count.sort_by{|k, v| v}.reverse]

result = user_total_count_sorted.map{ |key, value| 
	tester_info = testers_array.find {|tester| tester["testerId"] == key}
	tester_info["firstName"] + " " + tester_info["lastName"]} 


print "The results of your search are users ", result