workflow create-resources
{
$c = Get-AutomationConnection -Name 'AzureRunAsConnection' 
Add-AzureRmAccount -ServicePrincipal -Tenant $c.TenantID -ApplicationID $c.ApplicationID -CertificateThumbprint $c.CertificateThumbprint 
$rg = Get-AutomationVariable -Name 'ResourceGroupName'
$location = Get-AutomationVariable -Name 'Location'
$storageAccountName = Get-AutomationVariable -Name 'storageAccountName'
$vaultName = Get-AutomationVariable -Name 'vaultName'

InlineScript{
#Resource Group Creation
$resourceGroup = Get-AzureRmResourceGroup `
        -Name $using:rg `
        -Location $using:location -ErrorAction SilentlyContinue
Write-Output $resourceGroup
if(!$resourceGroup){
Write-Output "Creating resource group '$resourceGroupName' in location $location";
New-AzureRmResourceGroup -Name $using:rg -Location $using:location -Tag @{Department="Cloud Choice";Author="Kumar";} -Verbose 
}
else{
Write-Output "Using existing resource group '$resourceGroupName'";
}
#Storage Account Creation
$storageName = Get-AzureRmStorageAccount -ResourceGroupName $using:rg -Name $using:storageAccountName -ErrorAction SilentlyContinue
Write-Output $storageName
    if(!$storageName){
Write-Output "Creating Storage Account '$storageAccountName' in location $location";
New-AzureRmStorageAccount `
        -Location $using:location `
        -SkuName Standard_LRS `
        -Kind StorageV2 `
        -Tag @{Department="Cloud Choice";Author="Kumar";} `
        -Name $using:storageAccountName `
        -ResourceGroupName $using:rg
}
else{
Write-Output "Using existing Storage Account '$storageAccountName'";
}
#KeyVault Creation
$vName = Get-AzureRmKeyVault `
        -InRemovedState `
        -Location $using:location `
        -VaultName $using:vaultName -ErrorAction SilentlyContinue
Write-Output $vName
    if(!$vName){
Write-Output "Creating Key Vault '$vaultName' in location $location";
New-AzureRmKeyVault `
        -Name $using:vaultName `
        -EnabledForDeployment `
        -EnabledForTemplateDeployment `
        -Sku Standard `
        -Location $using:location `
        -ResourceGroupName $using:rg `
        -EnabledForDiskEncryption `
        -Tag @{Department="Cloud Choice";Author="Kumar";}
$j = Set-AzureRmKeyVaultAccessPolicy `
        -VaultName $using:vaultName `
        -PermissionsToSecrets get, set `
        -ObjectId (Get-AzureRmADGroup -SearchString 'seyoniacowner')[0].Id `
        -ResourceGroupName $using:rg `
        -PermissionsToKeys get, create  
Write-Output $j
}
else{
Write-Output "Using existing Storage Account '$storageAccountName'";
}
Write-Output "Set Azure RM KeyVault Access policy"
}
}
