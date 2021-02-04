﻿cls
## ------------------------------------------
##
##Script: MigrationToTeamsDNSCheck
##Version: V1.1
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
$domains = Get-AzureADDomain

write-host "-------------------------------------------------"
write-host $domains.Count "Domains found in the tenant"
write-host "-------------------------------------------------"
#Step 5 - Check SFB DNS records
write-host "-------------------------------------------------"
write-host "Checking Skype for Business hardcoded DNS Records:"
write-host "-------------------------------------------------"
$warningflag = $false
Foreach($i in $domains)
{
    $DNSonline = "is pointing to an Online environment:"
    $DNSOnPremises = "is NOT poiting to Online environment: "
    $DNSARecord = "is poiting to an A record - unable to determine: "
    
    if ($i.name.Contains("onmicrosoft.com")){
        write-host ""
        write-host "DOMAIN: " $i.name -BackgroundColor DarkGreen
        write-host $i.name "it's the default O365 domain from the tenant, does not require any validations."
    }
    else{
        write-host ""
        write-host "DOMAIN: " $i.name -BackgroundColor DarkGreen
        #-------------------------------------  
        $DNS_Lyncdiscover = "lyncdiscover."+$i.Name.ToString()
            try{
                $resolution = Resolve-DnsName -Name $DNS_Lyncdiscover -type ALL -DnsOnly -ErrorAction Stop
                
                if ($resolution.NameHost.ToString() -eq "webdir.online.lync.com")
                {
                    
                    write-host $DNS_Lyncdiscover $DNSonline $resolution.NameHost
                }

                else{
                    write-host $DNS_Lyncdiscover $DNSOnPremises $resolution.NameHost -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
            }catch{ 
                if ($resolution.Type -eq "A"){
                    write-host $DNS_Lyncdiscover $DNSARecord $resolution.IPaddress -BackgroundColor DarkYellow
                }
                else{
                write-host $Error[0].Exception.Message -BackgroundColor Red
                }
            }
        #-------------------------------------    
        $DNS_SIP = "sip."+$i.Name.ToString()
            try{
                $resolution = Resolve-DnsName -Name $DNS_SIP -type ALL -DnsOnly -ErrorAction Stop
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
                    write-host $DNS_SIP $DNSARecord $resolution.IPaddress -BackgroundColor DarkYellow
                }
                else{
                write-host $Error[0].Exception.Message -BackgroundColor Red
                }
            }
        #-------------------------------------  
        $DNS_SRVSIP = "_sip._tls."+$i.Name.ToString()
            try{
                $resolution = Resolve-DnsName -Name $DNS_SRVSIP -Type SRV -DnsOnly -ErrorAction Stop
                if ($resolution.NameTarget.ToString() -eq "sipdir.online.lync.com")
                {
                    write-host $DNS_SRVSIP $DNSonline $resolution.NameTarget
                }
                else{
                    write-host $DNS_SRVSIP $DNSOnPremises $resolution.NameTarget -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
            }catch{ 
                write-host $Error[0].Exception.Message -BackgroundColor Red
            }

        #-------------------------------------  
        $DNS_SRVSIPFED = "_sipfederationtls._tcp."+$i.Name.ToString()
            try{
                $resolution = Resolve-DnsName -Name $DNS_SRVSIPFED -Type SRV -DnsOnly -ErrorAction Stop
                if ($resolution.NameTarget.ToString() -eq "sipfed.online.lync.com")
                {
                    write-host $DNS_SRVSIPFED $DNSonline $resolution.NameTarget
                }
                else{
                    write-host $DNS_SRVSIPFED $DNSOnPremises $resolution.NameTarget -BackgroundColor Yellow -ForegroundColor Black
                    $warningflag = $true
                }
            }catch{ 
                write-host $Error[0].Exception.Message -BackgroundColor Red
            }
        #-------------------------------------  
        }

}


if ($warningflag){
    write-host ""
    write-host "-------------------------------------------------"
    write-host "WARNINGS:" -BackgroundColor Yellow -ForegroundColor Black
    write-host "Seems that you currently have some records not pointing to the Online Services."
    write-host "This is normally caused when there are still an Skype for Business on-premises environment deployed."
    write-host "If you are planning to migrate to TeamsOnly mode, please make sure that all the DNS records are poiting to online, or if you don't plan to use that doamin, delete the DNS records."
    write-host "For more details, see http://aka.ms/UpgradeToTeams"
    write-host "-------------------------------------------------"
} else{
    write-host ""
    write-host "-------------------------------------------------"
    write-host "200OK" -BackgroundColor DarkGreen
    write-host "All the DNS records are currently poiting to Online."
    write-host "You can now migrate your tenant to TeamsOnly Mode."
    write-host "-------------------------------------------------"
    }
