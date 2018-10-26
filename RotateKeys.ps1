workflow RotateKeys
{
$c = Get-AutomationConnection -Name 'AzureRunAsConnection' 
Add-AzureRmAccount -ServicePrincipal -Tenant $c.TenantID -ApplicationID $c.ApplicationID -CertificateThumbprint $c.CertificateThumbprint 
$rg = Get-AutomationVariable -Name 'ResourceGroupName'
$location = Get-AutomationVariable -Name 'Location'
$storageAccountName = Get-AutomationVariable -Name 'storageAccountName'
$vaultName = Get-AutomationVariable -Name 'vaultName'

InlineScript{
$storageName = Get-AzureRmStorageAccount -ResourceGroupName $using:rg -Name $using:storageAccountName -ErrorAction SilentlyContinue
Write-Output $storageName
#step 2
    if($storageName){
$i = Get-AzureRmStorageAccountKey -ResourceGroupName $using:rg -Name $using:storageAccountName
Write-Output $i.GetValue(1).Value
$secretvalue = ConvertTo-SecureString $i.GetValue(1).Value -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $using:vaultName -Name $using:storageAccountName -SecretValue $secretvalue
#step 3
New-AzureRmStorageAccountKey `
        -ResourceGroupName $using:rg `
        -Name $using:storageAccountName `
        -KeyName key1
#step 4
$i = Get-AzureRmStorageAccountKey -ResourceGroupName $using:rg -Name $using:storageAccountName
Write-Output $i.GetValue(0).Value
$secretvalue = ConvertTo-SecureString $i.GetValue(0).Value -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $using:vaultName -Name $using:storageAccountName -SecretValue $secretvalue 
#step 5 
New-AzureRmStorageAccountKey `
        -ResourceGroupName $using:rg `
        -Name $using:storageAccountName `
        -KeyName key2 
}
}
}