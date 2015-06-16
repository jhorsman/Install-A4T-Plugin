$filename = "HelloWorld.a4t"  
$pluginName = "HelloWorld"     #todo read plugin name from archive
$cmsHostname = "http://localhost"

try
{
    #todo add configuration options
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
        $pluginIsInstalled = $plugins.name.Contains($pluginName)
    }

    if($pluginIsInstalled)
    {
        Write-Host "$pluginName is installed"
    } else 
    {
        Write-Host "$pluginName is not installed"
    }

    $file = Get-Item ".\$filename"
    #check for /plugin/name without spaces in a4t.xml

    if($pluginIsInstalled) 
    {
        $response = $webclient.UploadString($cmsHostname + "Alchemy/api/Plugins/" + $pluginName + "/Uninstall", "")
        Write-Host "Uninstalled module $pluginName"
    }

    $response = $webclient.UploadFile($cmsHostname + "Alchemy/api/Plugins/Install", $file)
    Write-Host "Installed module $pluginName"
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