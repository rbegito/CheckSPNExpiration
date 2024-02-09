#VARIABLES FOR CLI
tenantID="6ce3959a-c01e-45e4-902d-5f0196c9ecc4"
SubscriptionID="867daae0-0e98-4fec-ada5-18d7147eb740"

ResourceGroup='rg-automation'
staname="checkspnxpirationsta01"
Location='eastus2'
AutoAcctName="CheckSPNExpiration"
Runbookname="RunBookExpiringSecrets"
ContainerName='myreportsblobs'

#VARIABLE


az login --tenant $tenantID
az account set --subscription  $SubscriptionID



 New-AzResourceGroup -Name $ResourceGroup -Location $Location 
 
 $StorageHT = @{                                                                                                                                                                          
   ResourceGroupName = $ResourceGroup
   Name              = $staname
   SkuName           = 'Standard_LRS'
   Location          = $Location
} 

$StorageAccount = New-AzStorageAccount @StorageHT
$Context = $StorageAccount.Context

New-AzStorageContainer -Name $ContainerName -Context $Context




$stakey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroup -Name $staname)[0].Value


az automation account create --automation-account-name $AutoAcctName --resource-group $ResourceGroup --location $Location
az automation runbook create --automation-account-name $AutoAcctName --resource-group $ResourceGroup   --name $Runbookname --type "PowerShell" --location $Location

az automation runbook replace-content --automation-account-name $AutoAcctName --resource-group "rg-automation" --name "RunBookExpiringSecrets" --content @./script.ps1

az automation runbook publish --automation-account-name $AutoAcctName --resource-group $ResourceGroup --name $Runbookname


az automation schedule create --automation-account-name $AutoAcctName  --resource-group $ResourceGroup   -n checkSPNSchedule --frequency Hour --interval 8 


## Powershell only
Set-AzAutomationAccount -ResourceGroupName $ResourceGroup -Name $AutoAcctName -AssignSystemIdentity


# after this step, Create a Credetial connection in the portal, need to assing a role that can read alll SPNs and write to the storage account































