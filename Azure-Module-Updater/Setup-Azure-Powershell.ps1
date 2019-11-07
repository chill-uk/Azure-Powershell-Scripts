
Write-Host -ForegroundColor Yellow "Welcome to the Azure module setup wizard"
Write-Host ""
#Pre-requisites
#Powershell version 5+, Elevated session, AzureRM powershell Module installed?, AZ powershell module installed?, Set PSGallery to trusted, install nuget
Write-Host -ForegroundColor DarkBlue "Checking Pre-Requisites"
Write-Host ""

#Check if Powershell gallery is trusted/untrusted
$psgallery = Get-PSRepository -name psgallery

function install_az_powershell{ 
Write-Host ""
Write-Host -ForegroundColor Yellow "Installing AZ powershell module"
    try {
        Write-host -ForegroundColor Yellow "Trusting PSGallery"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Write-host -ForegroundColor Green ">PSGallery is Trusted"
        Write-Host -ForegroundColor Yellow "Installing AZ powershell module"
        Install-Module -Name Az -erroraction stop
        Write-Host -ForegroundColor Green ">AZ powershell module installed"
        $AZ_installed = $True
    }
    catch {
        Write-Host -ForegroundColor Red ">Unable to install AZ Powershell module"
        Write-host -ForegroundColor Yellow "Rolling back changes"
        Write-host -ForegroundColor Yellow "Setting PSGallery to $($psgallery.InstallationPolicy)"
        Set-PSRepository -Name PSGallery -InstallationPolicy $psgallery.InstallationPolicy
        exit
    } 
}

#Check Powershell is version 5 or above
try {
    [System.Version]"$($PSversionTable.PSVersion)" -ge [System.Version]"5.1" > $null
    $Powershell_is_beta = $False
}
catch {
    Write-Host "Powershell version not compatible"
    $Powershell_is_beta = $True
    exit
}
if ($Powershell_is_beta -eq $False){
    if ([System.Version]"$($PSversionTable.PSVersion)" -ge [System.Version]"5.1"){
            Write-Host -ForegroundColor Yellow "Checking PS version"
            Write-Host -ForegroundColor Green ">PS version is compatible"
            #$Compatible = $true
    }
    else {
        Write-Host ""
        $PSVersionTable.PSVersion
        Write-Host -ForegroundColor Red ">PS version is not compatible"
        Write-Host -ForegroundColor Yellow ">Please download the latest Powreshell version for your system from here:"
        Write-Host -ForegroundColor White ">https://tinyurl.com/y3zm66ce"
        exit
    }
}

#Checking Elevated session
Write-Host -ForegroundColor Yellow "Checking for Admin rights"
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    #$admin = $False
    Write-Host -ForegroundColor Red ">Not an Admin"
    Write-Host -ForegroundColor Yellow ">Trying to elevate"
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit
    }
    catch {
        Write-Host -ForegroundColor Red ">Elevate Failed"
        Write-Host -ForegroundColor Yellow ">Try running the script as an Admin"
        exit       
    }
}
else {
    #$admin = $True
    Write-Host -ForegroundColor Green ">Admin rights confirmed"
}

#Is AzureRM powershell Module installed?
Write-Host -ForegroundColor Yellow "Checking if Legacy AzureRM module is installed"
try {
    (Get-InstalledModule -name AzureRM -erroraction stop).version > $null
    Write-Host -ForegroundColor Red ">AzureRM Module is Installed"
    $AzureRM_installed = $True
    } 
catch {
    Write-Host -ForegroundColor Green ">AzureRM Module not installed"
    $AzureRM_installed = $False
    }

#Is AZ powershell Module installed?
Write-Host -ForegroundColor Yellow "Checking if AZ module is installed"
try {
    (Get-InstalledModule -name AZ -erroraction stop).version > $null
    Write-Host -ForegroundColor Green ">AZ Module Installed"
    $AZ_installed = $True
    } 
catch {
    Write-Host -ForegroundColor Red ">AZ Module not installed"
    $AZ_installed = $False
    }

Write-Host ""
Write-Host -ForegroundColor Green "Pre-Requisites checks complete "
Write-Host ""
Write-Host -ForegroundColor Yellow "Configuraing system"
Write-Host ""

if ($AzureRM_installed -eq $true){
    if ($AZ_installed -eq $False){
        install_az_powershell
    }
    else{
        Write-Host -ForegroundColor Yellow "Removing legacy AzureRM powershell module"
        try {
            Uninstall-AzureRm -erroraction stop
            Write-Host -ForegroundColor Green ">AzureRM powershell module removed"
            $AzureRM_installed = $False
        }
        catch {
            Write-Host -ForegroundColor Red ">Can't uninstall AzureRM powershell module"
            Write-Host -ForegroundColor Red ">Please try removing it manually"
            Write-Host -ForegroundColor Red ">https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-2.0.0#uninstall-azure-powershell-msi"
            exit
        }
    }
}
else {
    if ($AZ_installed -eq $False){
        install_az_powershell
        Write-Host -ForegroundColor Yellow "Enabling legacy Azure module compatability"
        try {
            Enable-AzureRmAlias -Scope LocalMachine
            Write-Host -ForegroundColor Green ">AzureRM Aliases enabled. All previous Azure powershell scripts are now compatible"           
        }
        catch {
            Write-Host -ForegroundColor Green ">Could not enable AzureRM Aliases. Please try running this command Enable-AzureRmAlias manually"           
        }
    }
    else {
        Write-Host -ForegroundColor Yellow "Checking for latest available version"
        $AZ_installed_version = Get-InstalledModule -name AZ
        $AZ_online_version = Find-Module -Name Az
        
        if ([version]$AZ_online_version.version -gt [version]$AZ_installed_version.version) {
            Write-Host -ForegroundColor Red ">Online update available"
            Update-Module -Name AZ -Confirm
        }
        else {
            Write-Host -ForegroundColor Green ">No new updates"
        }
        Write-Host -ForegroundColor Yellow "Enabling legacy Azure module compatability"
        try {
            Enable-AzureRmAlias -Scope LocalMachine
            Write-Host -ForegroundColor Green ">AzureRM Aliases enabled. All previous Azure powershell scripts are now compatible"           
        }
        catch {
            Write-Host -ForegroundColor Green ">Could not enable AzureRM Aliases. Please try running this command Enable-AzureRmAlias manually"           
        }
    }
}
		
if ((Get-PSRepository -name PSGallery).InstallationPolicy -ne $psgallery.InstallationPolicy) {
            Write-host -ForegroundColor Yellow "Cleaning up"
            Write-host -ForegroundColor Yellow "Setting PSGallery to $($psgallery.InstallationPolicy)"
            Set-PSRepository -Name PSGallery -InstallationPolicy $psgallery.InstallationPolicy
}

Write-Host -ForegroundColor Green ""
Write-Host -ForegroundColor Green "Finished wizard"
Write-Host -ForegroundColor Green ""
