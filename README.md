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

* Plugin name (optional); The name as defined in the module. Defaults to the file name. The plugin name should be read from the .a4t file but that is not implemented yet. 

* CMS URL (optional); URL of the Tridion Content Manager server. Defaults to "http://local host"

* Username (optional) Tridion CM user with administrator rights. when username and password are not provided the logged on user's credentials will be used.

* Password (optional)

Examples
=========
minimal
 `.\Install-A4T-Plugin.ps1 "HelloWorld.a4t"`

plugin name is different from file name
 `.\Install-A4T-Plugin.ps1 "HelloWorld-old-copy.a4t" "HelloWorld"`

remote Content Manager
 `.\Install-A4T-Plugin.ps1 "HelloWorld.a4t" -CmsHostname "http://cms" -Username administrator -Password secret`