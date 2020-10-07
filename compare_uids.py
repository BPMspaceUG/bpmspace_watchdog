import json
import datetime as dt

live_uid_json = "/data/live_uids.json"
backup_uid_list = "/data/backup_uids.list"
result_file = "/data/result"

# Read UIDs & timestamp from JSON file
data = json.load(open(live_uid_json, "r"))
live_uids = data["participant_ids"]
live_transmission_timestamp = data["timestamp"]

# Read backup DB UIDs from list
# timestamp doesn't have to be checked since if the backup is too much older than the live database, the UID similarity test will file anyways
backup_uids = [int(uid) for uid in open(backup_uid_list, "r").read().rstrip("\n").split("\n")]

def computeIntersectionSize():
    return len(list(set(live_uids) & set(backup_uids)))

# Execute logic based on intersection size of live and backup UIDs
intersection_size = computeIntersectionSize()
if intersection_size > 6:
    keyword = "OK"
    message = "Everything alright, UID intersection above specified threshold (6)"

else:
    keyword = "ERROR"
    message = f"Intersection size of {intersection_size} is lower than specified minimum (6)"

# Check if last backup received is older than 3 days
transmission_timestamp = dt.datetime.strptime(live_transmission_timestamp, "%Y-%m-%dT%H:%M:%S%z").replace(tzinfo=None)
if dt.datetime.now() -  transmission_timestamp > dt.timedelta(259200):
    keyword = "ERROR"
    message = "Last SQL dump received older than 3 days"

timestamp = str(dt.datetime.now())
with open(result_file, "w") as f:
    f.write(keyword+ "\n" + message + "\n" + timestamp)
