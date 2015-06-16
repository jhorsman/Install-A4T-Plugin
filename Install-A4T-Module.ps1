$file = Get-Item ".\Servicer (1).a4t"
$moduleName = "Servicer"
$cmsHostname = "http://localhost/"

try
{
    #$creds = Get-Credential
    $cred = [System.Net.CredentialCache]::DefaultCredentials
    $webclient = new-object System.Net.WebClient
    $webclient.Credentials = $creds

    try
    {
        $response = $webclient.DownloadString($cmsHostname + "Alchemy/api/Plugins")
    }
    catch [System.Net.WebException]
    {
        Write-Error "Something went wrong there. Alchemy4Tridion might not be installed."
        throw $_
    }

    $plugins = ConvertFrom-Json($response)
    $pluginIsInstalled = $false
    if($plugins)
    {
        $pluginIsInstalled = $plugins.name.Contains($moduleName)
    }

    if($pluginIsInstalled)
    {
        Write-Host "$moduleName is installed"
    } else 
    {
        Write-Host "$moduleName is not installed"
    }

    if($pluginIsInstalled) 
    {
        $response = $webclient.UploadString($cmsHostname + "Alchemy/api/Plugins/Servicer/Uninstall", "")
        Write-Host "Uninstalled module $moduleName"
    }

    $response = $webclient.UploadFile($cmsHostname + "http://localhost/Alchemy/api/Plugins/Install", $file)
    Write-Host "Installed module $moduleName"
}
catch [System.Net.WebException]
{
    Write-Output "3"
    Write-Error $_;
    return $null;
}
catch [System.Exception]
{
    Write-Output "4" 
    Write-Error $_;
    return $null;
}