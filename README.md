# MigrationToTeamsDNSCheck
Powershell Script used to query all Skype for Business hardcoded DNS's to help you migrate the tenant to TeamsOnly Mode
##  Intructions: 
####  1. Run the following cmdlet: "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"
####  2. Install Azure AD Module. Run the following cmdlet: "Install-Module -Name AzureAD"
####  3. Office 365 admin rights to get the list of domains automatically
####
##  Details: 
Once you execute the script, you will be prompt to enter your Office 365 credentials.
The credentials will be used to obtain all the domains automatically from the tenant - "Get-AzureADDomain".
#### The scrip will detect the DNS that does not exists.
#### The scrip will detect the DNS that are poiting to Online.
#### The scrip will detect the DNS that are poiting to On-Premises.
![alt text](https://github.com/tiagoroxo/MigrationToTeamsDNSCheck/blob/[branch]/image.jpg?raw=true)
