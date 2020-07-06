live_uid_file = "live_uids.list"
backup_uid_file = "backup_uids.list"

live_uids = open(live_uid_file, "r").read().rstrip("\n").split("\n")
backup_uids = open(backup_uid_file, "r").read().rstrip("\n").split("\n")

def checkForShift():
    i = j = match_size = 0
    while True:
        if live_uids[i] == backup_uids[j]:
            if i == 9:
                return match_size + 1
            else:
                i += 1
                j += 1
                match_size += 1
        else:
            i += 1
            j = 0
            match_size = 0
            
def computeIntersectionSize():
    return len(list(set(live_uids) & set(backup_uids)))

print(computeIntersectionSize())
