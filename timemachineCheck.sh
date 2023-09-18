#!/bin/bash

#  Author: Jared Nay
#  Purpose: 7-day Time Machine Backup Monitor.
#+ This was designed for use with Datto RMM.
#+ THIS CURRENTLY ONLY WORKS WHEN THE BACKUP DRIVE IS MOUNTED.
#  Version: 20230917

# This will be the output from your script.
BackupFileName=""
ExitCode=0  # This would be set to 0 or 1 somewhere in your script.

# Run tmutil latestbackup command and capture the output
backup=$(tmutil latestbackup 2>/dev/null)

# Check if the command succeeded and extract the backup name
if [ $? -eq 0 ]; then
  BackupFileName=$(echo "$backup" | rev | cut -d "/" -f 1 | rev)
fi

# Check if BackupFileName variable is empty
if [ -z "$BackupFileName" ]; then
  UDFOut="null"
  
  # Get the correct path of the values.xml file.
  XMLPath=$(find /var/root/.mono/registry -name "values.xml")
  
  # Create a string variable of the content of the values.xml file barring the last line.
  XMLTemp=$(cat "$XMLPath" | grep -v "</values>")
  
  # Append the UDFOut variable to the string variable containing the contents of values.xml. You must replace X with a number 1-10 for the respective UDF.
  XMLTemp="$XMLTemp"$'\n'"<value name=\"Custom6\" type=\"string\">$UDFOut Days Since Last Backup</value>"$'\n'"</values>"

  # Delete the original values.xml
  rm "$XMLPath"

  # Copy the contents of the original values.xml plus append into a new values.xml
  echo "$XMLTemp" >> "$XMLPath"

  # Exit with the respective ExitCode.
  exit "$ExitCode"
else
  # Remove ".backup" extension from BackupFileName
  UDFOut="${BackupFileName%.backup}"

  # Get the current timestamp
  currentTimestamp=$(date "+%Y-%m-%d-%H%M%S")

  # Convert the UDFOut timestamp and current timestamp to Unix timestamps
  UDFOutTimestamp=$(date -j -f "%Y-%m-%d-%H%M%S" "$UDFOut" "+%s")
  currentTimestamp=$(date -j -f "%Y-%m-%d-%H%M%S" "$currentTimestamp" "+%s")

  # Calculate the time difference in seconds
  timeDifference=$((currentTimestamp - UDFOutTimestamp))

  # Convert the time difference to days rounded down
  UDFOut=$((timeDifference / 86400))  # 86400 seconds in a day

  echo "Days Difference: $UDFOut"
  
  # Get the correct path of the values.xml file.
  XMLPath=$(find /var/root/.mono/registry -name "values.xml")
  # Create a string variable of the content of the values.xml file barring the last line.
  XMLTemp=$(cat "$XMLPath" | grep -v "</values>")
  # Append the UDFOut variable to the string variable containing the contents of values.xml. You must replace X with a number 1-10 for the respective UDF.
  XMLTemp="$XMLTemp"$'\n'"<value name=\"Custom6\" type=\"string\">$UDFOut Days Since Last Backup</value>"$'\n'"</values>"

  # Delete the original values.xml
  rm "$XMLPath"
  # Copy the contents of the original values.xml plus append into a new values.xml
  echo "$XMLTemp" >> "$XMLPath"

if [ "$UDFOut" -gt 7 ]; then
  echo '<-Start Result->'
  echo "ALERT: $UDFOut since last backup!"
  echo '<-End Result->'
  exit 1
else
  echo '<-Start Result->'
  echo "Status: $UDFOut since last backup."
  echo '<-End Result->'
  exit "$ExitCode"
fi
fi