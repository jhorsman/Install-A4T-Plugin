# Usage examples
#   .\Install-A4T-Plugin.ps1 "HelloWorld.a4t"
#   .\Install-A4T-Plugin.ps1 "HelloWorld-old-copy.a4t" "HelloWorld"
#   .\Install-A4T-Plugin.ps1 "HelloWorld.a4t" -CmsHostname "http://cms" -Username administrator -Password secret

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

    #todo check for /plugin/name without spaces in a4t.xml

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
    $installedPlugin = $plugins.Where{$_.name -eq $PluginName}
    $pluginIsInstalled = ($installedPlugin.Count -eq 1)

    $installedPluginIsDeveloperVersion = $null
    if($pluginIsInstalled)
    {
        Write-Host "$PluginName is installed; Version: $($installedPlugin.versionNumber); VersionId: $($installedPlugin.versionId)"
        $pluginIsDeveloperVersion = ([string]::IsNullOrEmpty($installedPlugin.versionNumber) -or [string]::IsNullOrEmpty($installedPlugin.versionId))
        if($pluginIsDeveloperVersion)
        {
            Write-Host "The installed plugin is a development version"
        }
    } else 
    {
        Write-Host "$PluginName is not installed"
    }

    #todo compare with plugin version in .a4t file
    #check for /plugin/name without spaces in a4t.xml

    if($pluginIsInstalled) 
    {
        try{
            Write-Host "Uninstalling plugin $PluginName..."
            $response = $webclient.UploadString($CmsHostname + "Alchemy/api/Plugins/" + $PluginName + "/Uninstall", "")
            Write-Host "Uninstalled plugin $PluginName"
        }
        catch [System.Net.WebException]
        {
            $exception = $_
            Write-Error "Something went wrong while uninstalling plugin $PluginName"
            throw $exception
        }
    }

    $file = Get-Item "$Filename"
         
    try
    {
        Write-Host "Installing plugin $PluginName..."
        $response = $webclient.UploadFile($CmsHostname + "Alchemy/api/Plugins/Install", $file)
        Write-Host "Installed plugin $PluginName"
    }
    catch [System.Net.WebException]
    {
        $exception = $_
        Write-Error "Something went wrong while installing plugin $PluginName"
        throw $exception
    }
    Write-Host "done!"
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