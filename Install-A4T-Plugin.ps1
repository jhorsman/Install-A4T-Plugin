#upload.ps1' .\HelloWorld.a4t HelloWorld


param (
    [parameter(Mandatory=$true)]
    [string] $Filename,

    [string] $PluginName,

    [string] $CmsHostname = "http://localhost",

    #username and password are optional. The script defaults to the logged on user's credentials
    [string] $Username = "",

    [string] $Password = ""

)


$ErrorActionPreference = "Stop"

try
{
    Write-Host "Using filename $Filename"

    if(!(Test-Path($Filename)))
    {
        Write-Error "File $Filename does not exits"
        exit
    }

    if(!$PluginName)
    {
        $PluginName = [io.fileinfo] $Filename | % basename
    }
    Write-Host "using plugin name $PluginName"

    $webclient = new-object System.Net.WebClient
    if($Username -and $Password)
    {
        Write-Host "using provided credentials for user $Username"
        $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $webclient.UseDefaultCredentials = $false
        $webclient.Credentials = New-Object -TypeName System.Management.Automation.PSCredential ($Username, $securePassword)
    } else 
    {
        Write-Host "using default (logged on user's) credentials" 
        $webclient.UseDefaultCredentials = $true
    }


    if($CmsHostname.EndsWith("/") -eq $false)
    {
        $CmsHostname = $CmsHostname + "/"
    }

    try
    {
        $response = $webclient.DownloadString($CmsHostname + "Alchemy/api/Plugins")
    }
    catch [System.Net.WebException]
    {
        $exception = $_
        if($exception.Exception.Message.Contains("(401)"))
        {
            Write-Error "Authentication error"
            throw $exception
        }
        Write-Error "Something went wrong there. Alchemy4Tridion might not be installed."
        throw $exception
    }

    $plugins = ConvertFrom-Json($response)
    $pluginIsInstalled = $false
    if($plugins)
    {
        $pluginIsInstalled = $plugins.name.Contains($PluginName)
    }

    if($pluginIsInstalled)
    {
        Write-Host "$PluginName is installed"
    } else 
    {
        Write-Host "$PluginName is not installed"
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