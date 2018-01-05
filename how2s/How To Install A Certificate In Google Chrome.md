# How To Install A Certificate In Google Chrome (images to come later)
* Get the root\_ca certificate (default path is /etc/pki/elk/certs/server\_root.pem) and put it somewhere on your machine
* Open up Google Chrome and click the menu button in the top right hand corner
* Click 'Settings' and scroll down to the bottom. Expand the advanced setting
* Click on 'Manage Certificates'
* At the top of the new windows that opens up, click on 'Trusted Root Certification Authorities'
* Below the box that contains the list of certificates, click 'Import'
* Other than clicking all the buttons that say 'next', 'accept', and 'yes', you only have to click the button that says 'Browse' to find and install your certificate
* Close Google Chrome and reopen it. Navigate to a website that uses a certificate that is a child of the root certificate you just installed

TODO THROW AN EXAMPLE IN HERE FOR A WEBSITE TO NAVIGATE TO
