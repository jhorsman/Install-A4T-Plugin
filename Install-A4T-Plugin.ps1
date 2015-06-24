# Usage examples
#   .\Install-A4T-Plugin.ps1 "HelloWorld.a4t"
#   .\Install-A4T-Plugin.ps1 "HelloWorld.a4t" -CmsHostname "http://cms" -Username administrator -Password secret
#   .\Install-A4T-Plugin.ps1 "HelloWorld.a4t" -Verbose


#todo verbose mode

param (
    [parameter(Mandatory=$true)]
    [string] $Filename,

    [string] $CmsHostname = "http://localhost",

    #username and password are optional. The script defaults to the logged on user's credentials
    [string] $Username = "",

    [string] $Password = ""
)

$ErrorActionPreference = "Stop"

try
{
    Write-Verbose "Using filename $Filename"

    if(!(Test-Path($Filename)))
    {
        Write-Error "File $Filename does not exits"
        exit
    }

    #todo check for /plugin/name without spaces in a4t.xml

    $pluginName = $null
    try {
        $file = Get-Item($Filename)
        Add-Type -assembly system.io.compression.filesystem
        $a = [io.compression.zipfile]::OpenRead($file.FullName)
        $entries = $a.Entries.Where{$_.FullName -eq "a4t.xml"}
        #$entries.Count
        $entry = $entries[0]
        $stream = $entry.Open()
        $reader = new-object System.IO.StreamReader($stream)
        $content = [xml] $reader.ReadToEnd()
        $pluginName = $content["plugin"]["name"].InnerText
        #$content["plugin"]["id"].InnerText
        #$content["plugin"]["version"].InnerText
        #$content["plugin"]["versionId"].InnerText
    } catch {
        Write-Error "Something went wrong while reading $Filename. Are you sure this is an .a4t file?"
        throw $exception
    }

    if([string]::IsNullOrEmpty($pluginName))
    {
        Write-Error "Could not get plugin name from $Filename"
    }

    Write-Verbose "using plugin name $pluginName"

    $webclient = new-object System.Net.WebClient
    if($Username -and $Password)
    {
        Write-Verbose "using provided credentials for user $Username"
        $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $webclient.UseDefaultCredentials = $false
        $webclient.Credentials = New-Object -TypeName System.Management.Automation.PSCredential ($Username, $securePassword)
    } else 
    {
        Write-Verbose "using default (logged on user's) credentials" 
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
    $installedPlugin = $plugins.Where{$_.name -eq $pluginName}
    $pluginIsInstalled = ($installedPlugin.Count -eq 1)

    $installedPluginIsDeveloperVersion = $null
    if($pluginIsInstalled)
    {
        Write-Host "$pluginName is installed; Version: $($installedPlugin.versionNumber); VersionId: $($installedPlugin.versionId)"
        $pluginIsDeveloperVersion = ([string]::IsNullOrEmpty($installedPlugin.versionNumber) -or [string]::IsNullOrEmpty($installedPlugin.versionId))
        if($pluginIsDeveloperVersion)
        {
            Write-Verbose "The installed plugin is a development version"
        }
    } else 
    {
        Write-Verbose "$pluginName is not installed"
    }

    #todo compare with plugin version in .a4t file
    #check for /plugin/name without spaces in a4t.xml

    if($pluginIsInstalled) 
    {
        try{
            Write-Verbose "Uninstalling plugin $pluginName..."
            $response = $webclient.UploadString($CmsHostname + "Alchemy/api/Plugins/" + $pluginName + "/Uninstall", "")
            Write-Host "Uninstalled plugin $pluginName"
        }
        catch [System.Net.WebException]
        {
            $exception = $_
            Write-Error "Something went wrong while uninstalling plugin $pluginName"
            throw $exception
        }
    }

    $file = Get-Item "$Filename"

    try
    {
        Write-Verbose "Installing plugin $pluginName..."
        $response = $webclient.UploadFile($CmsHostname + "Alchemy/api/Plugins/Install", $file)
        Write-Host "Installed plugin $pluginName"
    }
    catch [System.Net.WebException]
    {
        $exception = $_
        Write-Error "Something went wrong while installing plugin $pluginName"
        throw $exception
    }
    Write-Verbose "done!"
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