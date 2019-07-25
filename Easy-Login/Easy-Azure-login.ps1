# "out-null" stops the mandatory subscription printout at the end.
Connect-AzAccount | out-null

$Subscription = Get-AzSubscription
Clear-Host
Write-Host -ForegroundColor Yellow "Here are your following subscriptions:"
 
For ($i=0; $i -lt $Subscription.Length; $i++) {
    Write-Host $i $Subscription.name[$i]
}
$i = Read-Host -Prompt "Please select the subscription your require" 
Select-AzSubscription -SubscriptionName $Subscription.name[$i]
