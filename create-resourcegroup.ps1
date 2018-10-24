workflow create-resourcegroup
{
    $c = Get-AutomationConnection -Name 'AzureRunAsConnection' 
    Add-AzureRmAccount -ServicePrincipal -Tenant $c.TenantID -ApplicationID $c.ApplicationID -CertificateThumbprint $c.CertificateThumbprint 

    $rg = Get-AutomationVariable -Name 'ResourceGroupName'
    $location = Get-AutomationVariable -Name 'Location'

 <#   
if(!$resourceGroup){
     Write-Host "Creating resource group '$resourceGroupName' in location $location";
    New-AzureRmResourceGroup -Name $rg -Location $location -Verbose 
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}
#>
    InlineScript{

    $resourceGroup = Get-AzureRmResourceGroup `
		-Name $using:rg `
		-Location $using:location

    if(!$resourceGroup){
     Write-Host "Creating resource group '$resourceGroupName' in location $location";
    New-AzureRmResourceGroup -Name $using:rg -Location $using:location -Verbose 
    }
    else{
    Write-Host "Using existing resource group '$resourceGroupName'";
    }
    }
}