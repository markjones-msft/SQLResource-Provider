# Get-SQLServersInSubscription

This script will check every VM in a subscription for the existence of SQL based on the existence of Registry Key: HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL

If the Key exists then the outputted CSV value will be set to True.

## To Use ##
To Use, Download both scripts to your local server / machine. To Run use Get-SQLServersInSubscription and update the parameter -Script with the location of Get-SQLRegKey.ps1 and an output for the CSV that the script will generate.

Output will be a CSV which includes the ResourceGroupName, ServerName, SQLServerInstalled, Verified.

## Dependencies ##
This script will require Invoke-AzVMRunCommand to be enabled and for for all VM's to be online.

