cls
## ------------------------------------------
##
##Script: MigrationToTeamsDNSCheck
##Version: V1
##Author: Tiago Roxo
##Description: Powershell Script used to query all Skype for Business hardcoded DNS's to help you migrate the tenant to TeamsOnly Mode
##DNS Queries:
## Lyncdiscover
## SIP
## _sip._tls.
## _sipfederationtls._tcp
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
                write-host $Error[0].Exception.Message -BackgroundColor Red
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
                write-host $Error[0].Exception.Message -BackgroundColor Red
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
    write-host "We obtained some warnings from the analyses above. Seems that you currently have some records not pointing to the Online Services."
    write-host "This is normally caused when there are still an SFB on-premises environment deployed. "
    write-host "If you are planning to migrate to TeamsOnly mode, please make sure that all the DNS records are poiting to online, or if you don't plan to use them, delete them."
    write-host "For more details, see http://aka.ms/UpgradeToTeams"
    write-host "-------------------------------------------------"
} else{
    write-host ""
    write-host "-------------------------------------------------"
    write-host "Migration to TeamsOnly it's good to go!"
    write-host "-------------------------------------------------"
    }
