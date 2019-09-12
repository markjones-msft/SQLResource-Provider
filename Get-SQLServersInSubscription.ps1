param (

    [String]    $SubscriptionID = "dffaebb6-0064-4b76-bf7f-6892b370bd81",
`   [String]    $Script = "C:\Code\CheckSQLStatus.ps1",
    [String]     $CSVPath = "C:\Code\SQLStatus.csv"

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
Add-Content -Path $CSVPath  -Value '"ResourceGroup","ServerName","HasSQLInstalled","Verified"'

$Servers = (get-azvm)

ForEach ($Server in $Servers)
{

    If ($server.name -like  "*sql*") 
        {
            Write-host -BackgroundColor Black -ForegroundColor Yellow "The server """ $server.Name """contains the word SQL in its name."
            if (($response = Read-host "Would you like to proceed and check if SQL is Installed on """ $server.Name """. (Press Y to Check for SQL Registry, N continue.") -eq "Y") 
                {
                               
                    # Test for Registry Path
                    $Status= Invoke-AzVMRunCommand -ResourceGroupName $Server.ResourceGroupName -Name $Server.Name -CommandId RunPowerShellScript -ScriptPath $Script 
                    write-host $Server.Name ", SQL Installed: " $Status.value.message

                    [PSCustomObject]@{'ResourceGroup' = $Server.ResourceGroupName
                                      'ServerName' = $Server.Name
                                      'HasSQLInstalled' = $Status.value.message
                                      'Verified' = "yes"
                    
                    } | Export-Csv -Path $CSVPath -Append
                    
                    $CSV = $CSV + @($Server.ResourceGroupName + ",", $Server.Name+ ",", $Status.value.message+ ",", "Yes")
                                           
                }
                ELSE
                {
                    write-host $Server.Name ", SQL Installed: False"
                    [PSCustomObject]@{'ResourceGroup' = $Server.ResourceGroupName
                                      'ServerName' = $Server.Name
                                      'HasSQLInstalled' = "Likely"
                                      'Verified' = "No"
                    
                    } | Export-Csv -Path $CSVPath -Append
                }

        }
        else
        {
             write-host $Server.Name ", SQL Installed: Not Checked (No SQL in name)"
            [PSCustomObject]@{'ResourceGroup' = $Server.ResourceGroupName
                'ServerName' = $Server.Name
                'HasSQLInstalled' = "Unlikely - No SQL in Servername"
                'Verified' = "No"
                } | Export-Csv -Path $CSVPath -Append
        }

}






