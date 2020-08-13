ids=$(mysql -u bwng_readonly -pc7S8zCjXabxFKGVRnbYh94suE5K7wJXE mitsm_business_warehouse -N -B -e "SELECT participant_id FROM participant ORDER BY participant_id DESC LIMIT 10;" | sed '$!s/$/, /' | tr -d "\n")
timestamp=$(date --iso-8601=seconds)
echo "{\"timestamp\": \"$timestamp\", \"participant_ids\": [$ids]}"
