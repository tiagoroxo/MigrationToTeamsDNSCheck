# MigrationToTeamsDNSCheck
Powershell Script used to query Skype for Business hardcoded DNS's to all your Domains part of the tenant, help you detect your current configuration, and help you migrate the tenant Coexistance mode to TeamsOnly.
##  Intructions: 
####  1. Open PowerShell and run the following cmdlet: "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"
####  2. Install/Update Microsoft Teams Powershell Module: 
- Install: Open PowerShell and run the following cmdlet: "Install-Module -Name MicrosoftTeams"
- Update: Open PowerShell and run the following cmdlet: "Update-Module MicrosoftTeams"
####  2.1. Confirm that you Teams Module at least on version 2.0.0:
- Run the following cmdlets to confirm module loaded:
- -> Import-Module MicrosoftTeams
- -> get-module
- Module Source: https://www.powershellgallery.com/packages/MicrosoftTeams/2.0.0
####  3. You will need Office 365 admin rights to get the list of domains automatically.
####  4. Once the above steps are completed, you can execute the script. Open a Powershell and execute scrip: MigrationToTeamsDNSCheck VXX.ps1
####
##  Details: 
- Once you execute the script, you will be prompt to enter your Office 365 credentials.
- The credentials will be used to obtain all the SIP Domains automatically from the tenant - "Get-CsOnlineSipDomain".
- This script will only list data, won't do any change.
#### The script will detect if the SIP Domains are disabled or Enabled.
#### The script will detect the DNS records that does not exists.
#### The script will detect the DNS records that are poiting to Online.
#### The script will detect the DNS records that are poiting to On-Premises.
#### The script currently only queries the followings DNS records:
- Lyncdiscover
- SIP
- _sip._tls.
-  _sipfederationtls._tcp
####
#### ----> Always use the most recent version of the Script <----
#### Tool:
![Tool](https://github.com/tiagoroxo/MigrationToTeamsDNSCheck/blob/main/tool.JPG?raw=true)
##  Kudos:
Thanks to everyone that is sending feedback to improve this analyser script.

## New updates are going to be published in the FastTrack Github: https://github.com/microsoft/FastTrack/tree/master/scripts/Get-MigrationToTeamsDNSCheck
