# "out-null" stops the mandatory subscription printout at the end.
Connect-AzAccount | out-null

$Subscription = Get-AzSubscription
Write-Host "Please select your subscrption"

For ($i=0; $i -lt $Subscription.Length; $i++) {
    Write-Host $i $Subscription.name[$i]
}
$i = Read-Host -Prompt "Please slect your Subscription" 
Select-AzSubscription -SubscriptionName $Subscription.name[$i]
