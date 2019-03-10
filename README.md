# About

This is a public repository of a script to set-up, from a fresh Windows 10 installation, a development or multimedia production environment with just a single command.

Of course this personal repository is configured to be adapter on my specific needs, but you are free to fork it and customise it as you wish.

# Set-up

From a powershell console, as an Administrator, just launch the following command:

`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Xeeynamo/setup/master/bootstrap.ps1'))`

# Features

* Disable useless Windows services
* Remove the damn pre-installed Windows Apps (addio Candy Crush Saga)
* Enable Developer Mode
* Make the taskbar decent for multi-monitor configurations
* Remove XPS and Fax services
* Enable Telnet, .Net Framework 3.5, Hyper-V and Linux Subsystem
* Disable telemetry
* Install Dracula theme
* Install a bunch of softwares
* Install a customized Start layout
* Restore a back-up of home folder

# To do

* Make the script more configurable
* Set-up a private repository that restores keys, licenses and personal information
* Create a back-up script that upload the current settings into the private backup repository
* Script that upgrade all the installed softwares
* Script that revert the changes made by this set-up script
