Function Get-KeysOrSecretsFromVault
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidatePattern("^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$")]
        [string]$SubscriptionId,
 
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateLength(1,128)] # String must be between 1 and 128 chars long 
        [string]$ResourseGroupName,
 
        [Parameter(Mandatory=$true, Position=2)]
        [ValidateLength(1,128)] # String must be between 1 and 128 chars long 
        [string]$KeyVaultName,
 
        [Parameter(Mandatory=$true, Position=3)]
        [ValidateSet('key','secret',IgnoreCase = $true)]  
        [string]$ListType,

        [Parameter(Mandatory=$true, Position=4)]
        [string]$username,
        
        [Parameter(Mandatory=$true, Position=5)]
        [string]$password
    )

    # Stop Executing when encountered error.
    $ErrorActionPreference = "Stop"


    #region Parameter Validation
     #Parameters
    Write-Host "Subscription Provided: $($SubscriptionId)"
    Write-Host "ResourceGroupName Provided: $($ResourseGroupName)"
    Write-Host "KeyVaultName Provided: $($KeyVaultName)"
    Write-Host "What to List: $($ListType)"

    $securepasswd = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($username, $securepasswd)
    Import-Module -Name AzureRM.Profile 
    Login-AzureRmAccount  -Credential $cred -TenantId "ad66c3d1-bd4d-41ee-b943-cdbb28ffa678" -SubscriptionId $SubscriptionId 
    
 
    If (!(Get-AzureRmKeyVault -VaultName $KeyVaultName)){
         Write-Error "$KeyVaultName - KeyVault doesnt Exist. Please provide a correct name";
    }
 
    #subscription selected as mentioned in variable above.
    Select-AzureRmSubscription -SubscriptionName $SubscriptionId

    
    #Load Keys from JSON
    switch ($ListType){
        key
            {
               Write-Host "Listing..... Keys"
               $secret = Get-AzureKeyVaultKey -VaultName $KeyVaultName
               $secret.foreach{ Get-AzureKeyVaultKey -VaultName $_.VaultName -Name $_.Name }|select-object Name ,Id
            }
        secret
            {
               Write-Host "Listing.... Secrets"
               $secret = Get-AzureKeyVaultSecret -VaultName $KeyVaultName
               $secret.foreach{ Get-AzureKeyVaultSecret -VaultName $_.VaultName -Name $_.Name }|select-object Name ,SecretValueText
            }
    }
    
    Write-Host "Script Finished Executing"
}