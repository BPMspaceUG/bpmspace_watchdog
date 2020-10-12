#!/bin/bash

html="<html><link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\" integrity=\"sha384-BVYiiSIFeK1dGmJRAkycuHAHRg320mUcww7on3RYdg4Va+PmSTsz/K68vbdEqh4u\" crossorigin=\"anonymous\"><body><div style=\"margin-top:30px;\" class=\"row\">"
html+="<div class=\"col-sm-12\">&nbsp</div>"
html+="<div class=\"col-sm-2\"></div>"
html+="<div class=\"col-sm-8\"<ul>"

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
backup_dir="/volume1/Backup/SE06/SQL/LATEST"

rsync -ua --stats --log-file=$logfile -e "ssh -p 7070" root@se6.mitsm.de:/home/backup/SQL/LATEST/* $backup_dir/
while read line; do
        html+="<li>$line</li>"
done < $logfile
html+="</ul><li>end DB se06</li>"

##########
# Finish #
##########
html+="</ul><div class=\"col-sm-2\"></div>"
html+="</div></body></html>"
echo $html > $html_output_destination/$logfilename.$logfiledate.htm # upload HTML output
