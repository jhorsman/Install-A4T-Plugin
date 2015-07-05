Install-A4T-Plugin
===============	

Install-A4T-Plugin is a script to help you install Alchemy 4 Tridion Plugins in the SDL Tridion Content Manager.

>Alchemy 4 Tridion (A4T) is a framework to help you develop SDL 
Tridion GUI extensions. Checkout their [web store](http://www.alchemywebstore.com)  and [GitHub projects](https://github.com/Alchemy4Tridion/Alchemy4Tridion/)

Install-A4T-Plugin is intended for use when developing A4T Plugins in Visual Studio, and for continuous deployment with i.e. Jenkins or Bamboo. With this script you can effortless install a plugin over and over again. A4T comes with a tool to upload your A4T plugin to alchemywebstore.com, by installing straight to the Tridion CM instead of going through the web store you will save quite a bit of development time.

Use
===
To install an Alchemy4Tridion plugin just call the Install-A4T-Plugin script with the following parameters.

* Path to .a4t file; this is an archive containing the Alchemy4Tridion plugin. You can download this from the Alchemy4Tridion store or get it from the Visual Studio build folder if you are developing a plugin.

* CMS URL (optional); URL of the Tridion Content Manager server. Defaults to "http://localhost"

* Username (optional) Tridion CM user with administrator rights. when username and password are not provided the logged on user's credentials will be used.

* Password (optional)

Examples
=========
minimal
 `.\Install-A4T-Plugin.ps1 "HelloWorld.a4t"`

remote Content Manager
 `.\Install-A4T-Plugin.ps1 "HelloWorld.a4t" -CmsHostname "http://cms" -Username administrator -Password secret`

verbose mode
 `.\Install-A4T-Plugin.ps1 "HelloWorld.a4t" -Verbose` 
 
Prerequisites
=============
This script requires PowerShell 4.0 and .NET 4.5, this because of the zip handling. This PowerShell and .NET versions come with

To run any downloaded script in PowerShell you have to change the Powershell execution policy. Set it to Allfor this script. On your content manager server you likely have this set up already because the [Tridion database](http://docs.sdl.com/LiveContent/content/en-US/SDL%20Tridion%20full%20documentation-v1/GUID-F056D405-1C30-446C-8FBA-9B723B73D999) and [DXA](http://docs.sdl.com/LiveContent/content/en-US/SDL%20Tridion%20Reference%20Implementation-v1/GUID-E8F826CF-A360-4223-BF16-8F9E1AF231EA) install scripts use PowerShell too.


