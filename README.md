# Set-up from a fresh install, with just one line of code

## About

This is a public repository of a script to set-up, from a fresh Windows 10 installation, a development or multimedia production environment with just a single command.

It will also tweak the UI, disable telemetry, uninstall pre-installed Windows apps and install all your favourite softwares.

Of course this personal repository is configured to be adapter on my specific needs, but you are free to fork it and [customize it](customization.md) as you wish.

## Set-up

From a powershell console, as an Administrator, just launch the following command:

`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Xeeynamo/setup/master/bootstrap.ps1'))`

Or if you want to avoid to launch the set-up (mostly for debugging purpose), launch the following command:

`Set-ExecutionPolicy Bypass -Scope Process -Force; $debug=$true; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Xeeynamo/setup/master/bootstrap.ps1'))`

## Customization

Please refer to [customization](customization.md) to discover how to configure your personal set-up script.

## Features

* Disable the specified Windows services
* Remove the damn pre-installed Windows Apps (goodbye Candy Crush Saga)
* Enable Developer Mode
* Tweak the taskbar for multi-monitor configurations
* Remove XPS and Fax services
* Enable Telnet, .Net Framework 3.5, Hyper-V and Linux Subsystem
* Install the latest Ubuntu LTS using WSL 1.0
* Disable telemetry
* Install Dracula theme on both Command Prompt and PowerShell
* Install your software from Chocolately in background
* Restore your backed-up Start layout
* Restore a back-up of home folder
* Install foobar2000 plugins
* Install Visual Studio Code extensions
* Install the latest version of Visual Studio, silently

## To do

* Make the script more configurable
* Install backed-up fonts
* Set-up a private repository that restores keys, licenses and personal information
* Create a back-up script that upload the current settings into the private backup repository
* Revert the changes made by the set-up script


## Bonus: Install Arch Linux

Just launch `curl https://raw.githubusercontent.com/Xeeynamo/setup/master/linux/pre.sh | sh`