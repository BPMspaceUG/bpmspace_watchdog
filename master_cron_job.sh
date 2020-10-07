docker_resource_directory="/volume1/backup_check"
cd $docker_resource_directory

# copy latest SQL dump from backup
docker-compose -f test-docker-compose.yml up -d

# Fetch live UID file output from se6
docker exec python wget --no-check-certificate https://mitsm.net:5050/oHGbuAiN014UmTHxHnViQGnfTkcBeW08lXYJp5go6Rcw9h2v6xh2vrGzI8HGbGAiN01DmToHGbuArZzbRRtBuAiNJ7ycqduoGOw/participant_ids.json ./data/live_uids.json

# Read out latest 10 UIDs from backup DB
# leaving out column title line
# Only run the query once the database is fully restored (i.e. the right table shows up in the table overview
echo "Restoring SQL dump, this might take a while..."
until docker exec db mysql -u root -proot -e "USE bwng; SHOW TABLES;" 2> /dev/null | grep "^participant$" -q;
do
	echo "Database not fully restored yet, sleeping for 10 seconds..."
	sleep 10;
done

docker exec db mysql -u root -proot -e "USE bwng; SELECT participant_id FROM participant ORDER BY participant_id DESC LIMIT 10;" | tail -n 10 > ./data/backup_uids.list
echo "Successfully queried SQL dump!"

# Run comparison script
echo "Running Python checking script..."
docker exec python python /tmp/compare_uids.py
echo "Successfully checked UIDs!"

# Clean up
docker-compose -f test-docker-compose.yml down -v
