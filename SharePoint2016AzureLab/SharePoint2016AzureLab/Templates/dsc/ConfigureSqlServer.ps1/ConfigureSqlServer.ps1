#
# Copyright="© Microsoft Corporation. All rights reserved."
#

configuration ConfigureSqlServer
{
    
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,
        
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SqlServerServiceAccountcreds,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SharePointSetupUserAccountcreds,
        [String]$DomainNetbiosName=(Get-NetBIOSName -DomainName $DomainName),
        [Int]$RetryCount=30,
        [Int]$RetryIntervalSec=60
    )

    Import-DscResource -ModuleName xComputerManagement, xNetworking, xActiveDirectory, xSql, xSQLServer, xSQLps, xDisk,cDisk
    WaitForSqlSetup

    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential]$SPSCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SharePointSetupUserAccountcreds.UserName)", $SharePointSetupUserAccountcreds.Password)
    [System.Management.Automation.PSCredential]$SQLCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($SqlServerServiceAccountcreds.UserName)", $SqlServerServiceAccountcreds.Password)

    Node localhost
    {
        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }
        cDiskNoRestart SQLDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
	    DependsOn="[xWaitForDisk]Disk2"
        }
        xWaitforDisk Disk3
        {
            DiskNumber = 3
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }
        cDiskNoRestart SQLLogDisk
        {
            DiskNumber = 3
            DriveLetter = "G"
            DependsOn="[xWaitForDisk]Disk3"
        }

        xFirewall DatabaseEngineFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = "1433"
            Ensure = "Present"
        }

        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
            DependsOn = "[cDiskNoRestart]SQLDataDisk","[cDiskNoRestart]SQLLogDisk"

        } 
        xWaitForADDomain DscForestWait 
        { 
            DomainName = $DomainName 
            DomainUserCredential= $Admincreds
            RetryCount = $RetryCount 
            RetryIntervalSec = $RetryIntervalSec 
            DependsOn = "[WindowsFeature]ADPS"      
        }

        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
            DependsOn = "[xWaitForADDomain]DscForestWait" 
        }

        xADUser CreateSqlServerServiceAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName = $DomainName
            UserName = $SqlServerServiceAccountcreds.UserName
            Password = $SQLCreds
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

        xSqlServer ConfigureSqlServer
        {
            InstanceName = $env:COMPUTERNAME
            SqlAdministratorCredential = $Admincreds
            ServiceCredential = $SQLCreds
            MaxDegreeOfParallelism = 1
            FilePath = "F:\DATA"
            LogPath = "G:\LOG"
            DomainAdministratorCredential = $DomainCreds
            DependsOn = "[xADUser]CreateSqlServerServiceAccount"
            
        }

        xADUser CreateSharePointSetupAccount
        {
            DomainAdministratorCredential = $DomainCreds
            DomainName = $DomainName
            UserName = $SharePointSetupUserAccountcreds.UserName
            Password = $SPSCreds
            Ensure = "Present"
            DependsOn = "[xComputer]DomainJoin"
        }

          
        xSqlLogin AddDomainAdminAccountToSysadminServerRole
        {
            Name = "${DomainNetbiosName}\$($Admincreds.UserName)"
            LoginType = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled = $true
            Credential = $Admincreds
            DependsOn = "[xSqlServer]ConfigureSqlServer"
        }

        xSqlLogin ConfigureSharePointSetupAccountSqlLogin
        {
            Name = "${DomainNetbiosName}\$($SharePointSetupUserAccountcreds.UserName)"
            LoginType = "WindowsUser"
            ServerRoles = "securityadmin","dbcreator"
            Enabled = $true
            Credential = $ADmincreds
            DependsOn = "[xADUser]CreateSharePointSetupAccount","[xSqlServer]ConfigureSqlServer"
        }
        LocalConfigurationManager 
        {
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
    }
}
function WaitForSqlSetup
{
    # Wait for SQL Server Setup to finish before proceeding.
    while ($true)
    {
        try
        {
            Get-ScheduledTaskInfo "\ConfigureSqlImageTasks\RunConfigureImage" -ErrorAction Stop
            Start-Sleep -Seconds 5
        }
        catch
        {
            break
        }
    }
}
function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(
        [string]$DomainName
    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            return $DomainName.Substring(0,15)
        }
        else {
            return $DomainName
        }
    }
}

