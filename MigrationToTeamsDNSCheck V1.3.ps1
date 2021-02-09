﻿cls
## ------------------------------------------
##
##Script: MigrationToTeamsDNSCheck
##Version: V1.3.1
##Author: Tiago Roxo
##Description: Powershell Script used to query all Skype for Business hardcoded DNS's to all your Domains part of the tenant, help you detect your current configuration, and help you migrate the tenant Coexistance mode to TeamsOnly.
## 
## ------------------------------------------

try{
	$hello = Get-AzureADTenantDetail
    cls
	
}catch{
	Connect-AzureAD
	Read-Host -Prompt "Press enter to Start"
}
cls
#Get the List of Domains from O365 Tenant
$domains = Get-AzureADDomain

write-host "-------------------------------------------------"
write-host $domains.Count "Domains found in the tenant"
write-host "-------------------------------------------------"
#Step 5 - Check SFB DNS records
write-host "-------------------------------------------------"
write-host "Checking Skype for Business hardcoded DNS Records:"
write-host "-------------------------------------------------"

##############################################################################################
$warningflag = $false
$DomainsToCheck = @()
$DNSServer = 8.8.8.8
$DNSonline = "-> DNS Record is pointing to an Online environment:"
$DNSOnPremises = "-> DNS Record is NOT pointing to Online environment: "
$DNSARecord = "-> DNS Record is pointing to an A record - unable to determine. Result: "
$DNSTXTRecord = "-> DNS Record is pointing to an TXT record. Result: "
$DNSError = "DNS name does not exist"
##############################################################################################

Foreach($i in $domains)
{
    #Ignores the queries to the default O365 Domain
    if ($i.name.Contains("onmicrosoft.com")){
        write-host ""
        write-host "DOMAIN: " $i.name -BackgroundColor DarkGreen
        write-host $i.name "it's the default O365 domain from the tenant, does not require any validations."
    }
    
    #Checks the DNS records for all domains part of the O365 tenant
    else{

        write-host ""
        write-host "DOMAIN: " $i.name -BackgroundColor DarkGreen
        #-------------------------------------  
        $DNS_Lyncdiscover = "lyncdiscover."+$i.Name.ToString()
	$resolution = $null
            try{
                $resolution = Resolve-DnsName -Name $DNS_Lyncdiscover -type ALL -Server $DNSServer -DnsOnly -ErrorAction Stop | where Section -eq "Answer"
                if ($resolution.NameHost.ToString() -eq "webdir.online.lync.com")
                {
                    
                    write-host $DNS_Lyncdiscover $DNSonline $resolution.NameHost
                }

                else{
                    write-host $DNS_Lyncdiscover $DNSOnPremises $resolution.NameHost -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                    $DomainsToCheck += $i.Name.ToString()
                }
            }catch{ 
                if ($resolution.Type -eq "A"){
                    write-host $DNS_Lyncdiscover $DNSARecord $resolution.IPaddress -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                    $DomainsToCheck += $i.Name.ToString()
                }
                if ($resolution.Type -eq "TXT"){
                    write-host $DNS_Lyncdiscover $DNSTXTRecord $resolution.Strings -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                    $DomainsToCheck += $i.Name.ToString()
                }
                if ($Error[0].Exception.Message.Contains($DNSError)){
                    write-host $DNS_Lyncdiscover "->"$DNSError -BackgroundColor Gray -ForegroundColor Black
                }
            }
        #-------------------------------------    
        $DNS_SIP = "sip."+$i.Name.ToString()
	$resolution = $null
            try{
                $resolution = Resolve-DnsName -Name $DNS_SIP -type ALL -Server $DNSServer -DnsOnly -ErrorAction Stop | where Section -eq "Answer"
                if ($resolution.NameHost.ToString() -eq "sipdir.online.lync.com")
                {
                    write-host $DNS_SIP $DNSonline $resolution.NameHost
                }
                else{
                    write-host $DNS_SIP $DNSOnPremises $resolution.NameHost -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true

                }
            }catch{ 
                if ($resolution.Type -eq "A"){
                    write-host $DNS_SIP $DNSARecord $resolution.IPaddress -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
                 if ($resolution.Type -eq "TXT"){
                    write-host $DNS_SIP $DNSTXTRecord $resolution.Strings -BackgroundColor Yellow -ForegroundColor Black
                }
                if ($Error[0].Exception.Message.Contains($DNSError)){
                    write-host $DNS_SIP "->"$DNSError -BackgroundColor Gray -ForegroundColor Black
                }
            }
        #-------------------------------------  
        $DNS_SRVSIP = "_sip._tls."+$i.Name.ToString()
	$resolution = $null
            try{
                $resolution = Resolve-DnsName -Name $DNS_SRVSIP -Type ALL -Server $DNSServer -DnsOnly -ErrorAction Stop | where Section -eq "Answer"
                if ($resolution.NameTarget.ToString() -eq "sipdir.online.lync.com")
                {
                    write-host $DNS_SRVSIP $DNSonline $resolution.NameTarget
                }
                else{
                    write-host $DNS_SRVSIP $DNSOnPremises $resolution.NameTarget -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
            }catch{ 
                if ($resolution.Type -eq "A"){
                    write-host $DNS_SRVSIP $DNSARecord $resolution.IPaddress -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
                 if ($resolution.Type -eq "TXT"){
                    write-host $DNS_SRVSIP $DNSTXTRecord $resolution.Strings -BackgroundColor Yellow -ForegroundColor Black
                }
                if ($Error[0].Exception.Message.Contains($DNSError)){
                    write-host $DNS_SRVSIP "->"$DNSError -BackgroundColor Gray -ForegroundColor Black
                }
            }

        #-------------------------------------  
        $DNS_SRVSIPFED = "_sipfederationtls._tcp."+$i.Name.ToString()
	$resolution = $null
            try{
                $resolution = Resolve-DnsName -Name $DNS_SRVSIPFED -Type ALL -Server $DNSServer -DnsOnly -ErrorAction Stop | where Section -eq "Answer"
                if ($resolution.NameTarget.ToString() -eq "sipfed.online.lync.com")
                {
                    write-host $DNS_SRVSIPFED $DNSonline $resolution.NameTarget
                }
                else{
                    write-host $DNS_SRVSIPFED $DNSOnPremises $resolution.NameTarget -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
            }catch{ 
                if ($resolution.Type -eq "A"){
                    write-host $DNS_SRVSIPFED $DNSARecord $resolution.IPaddress -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
                 if ($resolution.Type -eq "TXT"){
                    write-host $DNS_SRVSIPFED $DNSTXTRecord $resolution.Strings -BackgroundColor Yellow -ForegroundColor Black
                }
                if ($Error[0].Exception.Message.Contains($DNSError)){
                    write-host $DNS_SRVSIPFED "->"$DNSError -BackgroundColor Gray -ForegroundColor Black
                }
            }
        #-------------------------------------  
        }
}


if ($warningflag){
    write-host ""
    write-host "-------------------------------------------------"
    write-host "WARNINGS:" -BackgroundColor Yellow -ForegroundColor Black
    write-host "Domains that are requiring attention:"
    write-host "........."
    $DomainsToCheck
    write-host "........."
    write-host "This is normally caused when there are still an Skype for Business on-premises environment deployed or the DNS records are not properly configured."
    write-host "If you are planning to migrate to TeamsOnly mode, please make sure that all the DNS records are pointing to Online, or if you don't plan to use that Domain, delete the DNS records."
    write-host "For more details, see http://aka.ms/UpgradeToTeams"
    write-host "-------------------------------------------------"
} else{
    write-host ""
    write-host "-------------------------------------------------"
    write-host "200OK" -BackgroundColor DarkGreen
    write-host "The existing DNS records are currently poiting to the Online services."
    write-host "You can now migrate your tenant to TeamsOnly Mode."
    write-host "-------------------------------------------------"
    }
Read-Host -Prompt "Press enter to Finish"
