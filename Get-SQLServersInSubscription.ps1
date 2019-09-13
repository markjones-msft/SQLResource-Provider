param (

    [String]    $SubscriptionID = "",
`   [String]    $Script = "C:\Users\Documents\GitHub\Get-SQLServersInSubscription\Get-SQLRegKey.ps1",
    [String]     $CSVPath = "C:\Users\Documents\GitHub\Get-SQLServersInSubscription\SQLStatus.csv"

)

#Login-AzAccount

Select-AzSubscription   $SubscriptionID

$subscriptionMessage = ("Actually targeting Azure subscription: {0} " -f $subscriptionID)
Write-Host -BackgroundColor Black -ForegroundColor Yellow $subscriptionMessage

Write-host -BackgroundColor Black -ForegroundColor Yellow "The following servers are found in this subscription:"
write-host (Get-Azvm).Name


#########################################################################################
# Get All VMs in the subscription ad check for SQL based on Name and Registry
#########################################################################################
If((test-path $CSVPath) -eq "True") {del $CSVPath}
Add-Content -Path $CSVPath  -Value '"ResourceGroup","ServerName","HasSQLInstalled","ServerChecked"'

$Servers = (Get-Azvm)

if (($Response = Read-host "Would you like to check all servers or just those containing the word ""SQL"". (Press A to Check for ALL or any other key to just check Servers Contianing SQL.") -eq "A") 
    {$Response = "All"}

ForEach ($Server in $Servers)
{

    If ($server.name -like  "*sql*" -or $Response -eq "All") 
         {
                Write-host -BackgroundColor Black -ForegroundColor Yellow "Searching Registry on Server: " $server.Name
                                        
                # Test for Registry Path
                $Status= Invoke-AzVMRunCommand -ResourceGroupName $Server.ResourceGroupName -Name $Server.Name -CommandId RunPowerShellScript -ScriptPath $Script 
                $StatusFlag = $Status.value.message

                write-host $Server.Name ", SQL Installed: $StatusFlag"

                [PSCustomObject]@{'ResourceGroup' = $Server.ResourceGroupName
                                'ServerName' = $Server.Name
                                'HasSQLInstalled' = "$StatusFlag"
                                'ServerChecked' = "Yes"
                    
                } | Export-Csv -Path $CSVPath -Append
                 
        }
        else
        {
            
                write-host $Server.Name ", SQL Installed: Not Checked (No SQL in name)"

                [PSCustomObject]@{'ResourceGroup' = $Server.ResourceGroupName
                    'ServerName' = $Server.Name
                    'HasSQLInstalled' = "Unkown"
                    'ServerChecked' = "No"
                    } | Export-Csv -Path $CSVPath -Append
        }

}

