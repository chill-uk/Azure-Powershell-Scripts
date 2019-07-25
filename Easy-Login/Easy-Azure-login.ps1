# "out-null" stops the mandatory subscription printout at the end.
Connect-AzAccount | out-null

$Subscription = Get-AzSubscription
Clear-Host
Write-Host "Here are your following subscriptions"

For ($i=0; $i -lt $Subscription.Length; $i++) {
    Write-Host $i $Subscription.name[$i]
}
$i = Read-Host -Prompt "Please select your Subscription" 
Select-AzSubscription -SubscriptionName $Subscription.name[$i]
