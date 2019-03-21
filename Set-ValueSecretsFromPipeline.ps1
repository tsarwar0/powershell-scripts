Function Set-VaultSecretsFromPipeLine
{
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipeline=$true)]
        [HashTable]$secrets,
        
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
        [string]$username,
        
        [Parameter(Mandatory=$true, Position=4)]
        [string]$password

    )

    # Stop Executing when encountered error.
    $ErrorActionPreference = "Stop"

    #region Params
    Write-Host "Subscription Provided: $($SubscriptionId)"
    Write-Host "ResourceGroupName Provided: $($ResourseGroupName)"
    Write-Host "KeyVaultName Provided: $($KeyVaultName)"
    Write-Host "Filepath Provided: $($JsonFilePath)"
    #endregion


    
    #region AzureRelated
    $securepasswd = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($username, $securepasswd)
    Import-Module -Name AzureRM.Profile 
    Login-AzureRmAccount  -Credential $cred -TenantId "ad66c3d1-bd4d-41ee-b943-cdbb28ffa678" -SubscriptionId $SubscriptionId 


    If (!(Get-AzureRmKeyVault -VaultName $KeyVaultName)){
         Write-Error "$KeyVaultName - KeyVault doesnt Exist. Please provide a correct name";
    }

    #subscription selected as mentioned in variable above.
    Select-AzureRmSubscription -SubscriptionName $SubscriptionId

    #KeyVault provider added.
    Register-AzureRmResourceProvider -ProviderNamespace Microsoft.KeyVault

    #endregion

    #region KeyVault
        foreach($key in $secrets.Keys){
            Write-Host " Adding to Vault: $($key) ---$($secrets[$key])"
            $secretvalue = ConvertTo-SecureString $secrets[$key] -AsPlainText -Force
            $secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $($key) -SecretValue $secretvalue
        }
    #endregion
   
    Write-Host "Script Finished Executing"
}