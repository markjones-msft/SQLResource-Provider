if (Test-Path 'HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL') {$Status = 'True';} Else {$Status = 'False'; };
write-output $Status;
