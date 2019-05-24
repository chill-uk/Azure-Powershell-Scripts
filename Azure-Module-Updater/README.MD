This poweshell script performs the following functions:

#Pre-requisites checks:
#Powershell version 5+
#Elevated session 
#Are AzureRM powershell Module installed
#AZ powershell module installed
#Set PSGallery to trusted
#Install nuget

If the AzureRM modules are installed, this script will remove them using the "Uninstall-AzureRm" commandlet and enable AzureRM aliases so that your scripts written with AzureRM commands will still work.
If the AZ powershell modules are not found, it will install them from the PSGallery.

If the AZ powershell modulesa are found, it will compare the installed version against the latest version available from the PSGallery and install them if newer.

