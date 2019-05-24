
Write-Host -ForegroundColor Yellow "Welcome to the Azure module setup wizard"
Write-Host ""
#Pre-requisites
#Powershell version 5+, Elevated session, AzureRM powershell Module installed?, AZ powershell module installed?, Set PSGallery to trusted, install nuget
Write-Host -ForegroundColor Yellow "Checking Pre-Requisites"
Write-Host ""

#Check Powershell is version 5 or above
if ($PSVersionTable.PSVersion.Major -ge 5)
    {
        Write-Host -ForegroundColor Yellow "Checking PS version"
        Write-Host -ForegroundColor Green ">PS version is compatible"
        $Compatible = "True"
    }
else {
    Write-Host ""
        $PSVersionTable.PSVersion
        Write-Host -ForegroundColor Red ">PS version is not compatible"
        Write-Host -ForegroundColor Yellow ">Please download the latest Powreshell version for your system from here:"
        Write-Host -ForegroundColor White ">https://tinyurl.com/y3zm66ce"
        exit
}

#Checking Elevated session
Write-Host -ForegroundColor Yellow "Checking for Admin rights"
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    $admin = "False"
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
    $admin = "True"
    Write-Host -ForegroundColor Green ">Admin rights confirmed"
}

#Is AzureRM powershell Module installed?
Write-Host -ForegroundColor Yellow "Checking if Legacy AzureRM module is installed"
try {
    $AzureRM_Version_installed = Get-InstalledModule -name AzureRM -erroraction stop
    Write-Host -ForegroundColor Red ">AzureRM Module is Installed"
    $AzureRM_installed = "True"
    } 
catch {
    Write-Host -ForegroundColor Green ">AzureRM Module not installed"
    $AzureRM_installed = "False"
    }

#Is AZ powershell Module installed?
Write-Host -ForegroundColor Yellow "Checking if AZ module is installed"
try {
    $AZ_Version_installed = Get-InstalledModule -name AZ -erroraction stop
    Write-Host -ForegroundColor Green ">AZ Module Installed"
    $AZ_installed = "True"
    } 
catch {
    Write-Host -ForegroundColor Red ">AZ Module not installed"
    $AZ_installed = "False"
    }

Write-Host ""
Write-Host -ForegroundColor Green "Pre-Requisites checks complete "
Write-Host ""
Write-Host -ForegroundColor Yellow "Configuraing system"
Write-Host ""

if ($AzureRM_installed -eq "true"){
    if ($AZ_installed -eq "False"){
        Write-Host ""
        Write-Host -ForegroundColor Yellow "Installing AZ powershell module"
        try {
            Write-host -ForegroundColor Yellow "Trusting PSGallery"
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            Write-host -ForegroundColor Green "PSGallery is Trusted"
            Install-Module -Name Az -AllowClobber
            Write-Host -ForegroundColor Green ">AZ powershell module installed"
            $AZ_installed = "True"
        }
        catch {
            Write-Host -ForegroundColor Red ">Unable to insall AZ Powershell module"
            Write-host -ForegroundColor Yellow "Cleaning up"
            Write-host -ForegroundColor Yellow "Setting PSGallery to Untrusted"
            Set-PSRepository -Name PSGallery -InstallationPolicy Unrusted
            exit
        } 
    }
    else{
        Write-Host -ForegroundColor Yellow "Removing legacy AzureRM powershell module"
        try {
            Uninstall-AzureRm -erroraction stop
            Write-Host -ForegroundColor Green ">AzureRM powershell module removed"
            $AzureRM_installed = "False"
        }
        catch {
            Write-Host -ForegroundColor Red ">Can't uninstall AzureRM powershell module"
            Write-Host -ForegroundColor Red ">Please try removing it manually"
            Write-Host -ForegroundColor Red ">https://docs.microsoft.com/en-us/powershell/azure/uninstall-az-ps?view=azps-2.0.0#uninstall-azure-powershell-msi"
            exit
        }
        Write-Host -ForegroundColor Yellow "Enabling legacy Azure module compatability"
        Enable-AzureRmAlias
    }
}
else {
    if ($AZ_installed -eq "False"){
        Write-Host ""
        Write-Host -ForegroundColor Yellow "Installing AZ powershell module"
        try {
            Write-host -ForegroundColor Yellow "Trusting PSGallery"
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            Write-host -ForegroundColor Green ">PSGallery is Trusted"
            Write-Host -ForegroundColor Yellow "Installing AZ powershell module"
            Install-Module -Name Az -erroraction stop
            Write-Host -ForegroundColor Green ">AZ powershell module installed"
            $AZ_installed = "True"
        }
        catch {
            Write-Host -ForegroundColor Red ">Unable to install AZ Powershell module"
            Write-host -ForegroundColor Yellow ">Cleaning up"
            Write-host -ForegroundColor Yellow ">Setting PSGallery to Untrusted"
            Set-PSRepository -Name PSGallery -InstallationPolicy Unrusted
            exit
        } 
    }
    else {
        Write-Host -ForegroundColor Yellow "Checking for latest available version"
        $AZ_online_version = Get-InstalledModule -name AZ
        $AZ_installed_version = Find-Module -Name Az
        $AZ_installed_version_number = "$($AZ_online_version.version.major).$($AZ_online_version.version.minor).$($AZ_online_version.Version.Build)"
        $AZ_online_version_number = "$($AZ_installed_version.version.major).$($AZ_installed_version.version.minor).$($AZ_installed_version.Version.Build)"
        
        if ([version]$AZ_online_version_number -gt [version]$AZ_installed_version_number) {
            Write-Host -ForegroundColor Red ">Online update available"
            Update-Module -Name AZ -Confirm
        }
        else {
            Write-Host -ForegroundColor Green ">No new updates"
        }
        Write-Host -ForegroundColor Yellow "Enabling legacy Azure module compatability"
        try {
            Enable-AzureRmAlias
            Write-Host -ForegroundColor Green ">AzureRM Aliases enabled. All previous Azure powershell scripts are now compatible"           
        }
        catch {
            Write-Host -ForegroundColor Green ">Could not enable AzureRM Aliases. Please try running this command Enable-AzureRmAlias manually"           
        }
    }
}

$psgallery = Get-PSRepository -name psgallery
if ($psgallery_check.InstallationPolicy -eq "Trusted") {
            Write-host -ForegroundColor Yellow "Cleaning up"
            Write-host -ForegroundColor Yellow "Setting PSGallery to Untrusted"
            Set-PSRepository -Name PSGallery -InstallationPolicy Unrusted
}

Write-Host -ForegroundColor Green ""
Write-Host -ForegroundColor Green "Finished wizard"
Write-Host -ForegroundColor Green ""