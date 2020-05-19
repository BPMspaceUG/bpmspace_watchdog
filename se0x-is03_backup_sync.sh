#!/bin/bash


###########
# Methods #
###########

initialize_output_html () {
        html="<html><link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\" integrity=\"sha384-BVYiiSIFeK1dGmJRAkycuHAHRg320mUcww7on3RYdg4Va+PmSTsz/K68vbdEqh4u\" crossorigin=\"anonymous\"><body><div style=\"margin-top:30px;\" class=\"row\">"
        html+="<div class=\"col-sm-12\">&nbsp</div>"
        html+="<div class=\"col-sm-2\"></div>"
        html+="<div class=\"col-sm-8\"<ul>"
        echo $html
}

finish_output_html () {
        html=$1
        html+="</ul><div class=\"col-sm-2\"></div>"
        html+="</div></body></html>"
        echo $html
}

# Config
logpath="/var/services/homes/websync/scripts/logs"
logfiledate=$(date '+%s')
logfilename="se0x-is03_backup_sync"
html_output_destination="/dev/null"

# Prep
find $logpath -name "$logfilename*.log" -mmin +60 -delete # delete old log files
html="$(initialize_output_html)" # initialize output HTML

######################
# Get se06 DB backup #
######################
html+="<li>start DB se06</li><ul>"
logfile="$logpath/$logfilename.dbse06.$logfiledate.log"
backup_dir="/volume1/Backup/SE06"

# 1. rsync
rsync -ua --stats --log-file=$logfile -e "ssh -p 7070" root@se6.mitsm.de:/home/backup/SQL/LATEST $backup_dir/
while read line; do
        result+="<li>$line</li>"
done < $logfile
html+="</ul><li>end DB se06</li>"

# 2. Rename
# to better identify backup files and only have to download the "LATEST" folder every time
last_backup_time = $(ssh -t root@se6.mitsm.de -p 7070 "stat -c %y /home/backup/SQL/LATEST")
read Y M D h m _ _ _ <<< ${last_backup_time//[-:\. ]/ }
mv "$backup_dir/LATEST" "$backup_dir/$Y$M${D}_$h$m"

# 3. Delete backups older than 14 days
# i.e. all but the last 14 backup files, excluding the "old" directory
cd $backup_dir
ls -tp | grep -E -v "(old)" | tail -n +15 | xargs -I {} rmdir -- {} # detailed explanation at https://stackoverflow.com/questions/25785/delete-all-but-the-most-recent-x-files-in-bash


##########
# Finish #
##########
html="$(finish_output_html html)" # finish off HTML output
echo $html | $html_output_destination/$logfilename.$logfiledate.htm # upload HTML output
