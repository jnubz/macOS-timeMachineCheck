# macOS-timeMachineCheck

## Scope

This script will check for last successful Time Machine backup, and it checks to ensure a backup hass happened in the last 7 days.  

If there has been a backup within 7 days, it will output a successful `echo` to Datto RMM. If there has not been a backup, it will exit with a `1` and submit an alert to your dashboard. It can also be configured to automatically sent a ticket.

> NOTE: I Have not tested this with any other RMM, but the code should work with a little adjustment to where you send your values.
