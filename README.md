# PlexConnect-QNAP
QPKG for PlexConnect on QNAP with a simple UI page

This automatically takes care of web server forwarding and certificate generation, you only need to install the certificate on the AppleTV - with full instructions given on the options page.

**IMPORTANT: There is currently a bug which prevents this running automatically on status change, you need to manually ssh in and run `/share/MD0_DATA/.qpkg/PlexConnect/plexconnect.sh restart` when enabled!**

## Installation
* Log in to the QNAP web admin page
* Open the "App Center"
* Click "Install Manually" in the top right
* Browse and select the PlexConnect_*.qpkg (it includes the version in the name)
* Click Install

## Configuring
* Log in to the QNAP web admin page
* Open the "App Center"
* Click "Open" in the PlexConnect app
* Change any options and Submit to save
* Stop then restart the PlexConnect app

**NOTE:** *Changing the Channel requires installing the correct certificate for that channel!*

## Developing
* Install QDK (see http://wiki.qnap.com/wiki/QPKG_Development_Guidelines)
* Clone this repo into the QDK folder (normally `/share/MD0_DATA/.qpkg/QDK/`)
* Make changes and copy into the installed app for testing
* Run "`qbuild`" to create a new package
