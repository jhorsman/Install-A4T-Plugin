$file = Get-Item ".\HelloWorld.a4t"
$moduleName = "HelloWorld"
$cmsHostname = "http://localhost"

try
{
    #$creds = Get-Credential
    $cred = [System.Net.CredentialCache]::DefaultCredentials
    $webclient = new-object System.Net.WebClient
    $webclient.Credentials = $creds

    if($cmsHostname.EndsWith("/") -eq $false)
    {
        $cmsHostname = $cmsHostname + "/"
    }

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
        $response = $webclient.UploadString($cmsHostname + "Alchemy/api/Plugins/" + $moduleName + "/Uninstall", "")
        Write-Host "Uninstalled module $moduleName"
    }

    $response = $webclient.UploadFile($cmsHostname + "Alchemy/api/Plugins/Install", $file)
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