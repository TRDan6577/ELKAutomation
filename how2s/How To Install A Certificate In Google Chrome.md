# How To Install A Certificate In Google Chrome (images to come later)
* Get the root\_ca certificate (default path is /etc/pki/elk/certs/server\_root.pem) and put it somewhere on your machine
* Open up Google Chrome and click the menu button in the top right hand corner
* Click 'Settings'

![Step 1](https://raw.githubusercontent.com/TRDan6577/ELKAutomation/master/how2s/media/1.JPG)

* Scroll down to the bottom. Expand the advanced setting and click on 'Manage Certificates'

![Step 2](https://raw.githubusercontent.com/TRDan6577/ELKAutomation/master/how2s/media/2.JPG)

* At the top of the new windows that opens up, click on 'Trusted Root Certification Authorities'
* Below the box that contains the list of certificates, click 'Import'

![Step 3](https://raw.githubusercontent.com/TRDan6577/ELKAutomation/master/how2s/media/3.JPG)

* Other than clicking all the buttons that say 'next', 'accept', and 'yes', you only have to 
click the button that says 'Browse' to find and install your certificate

![Step 4](https://raw.githubusercontent.com/TRDan6577/ELKAutomation/master/how2s/media/4.JPG)

* On Microsoft Windows, another window will pop up asking if you're absolutely positive that you
want to have this root certificate on your machine. You're pretty positive, right? Click 'Yes'

![Step 5](https://raw.githubusercontent.com/TRDan6577/ELKAutomation/master/how2s/media/5.JPG)

* Close Google Chrome and reopen it. Navigate to a website that uses a certificate that is a 
child of the root certificate you just installed

TODO THROW AN EXAMPLE IN HERE FOR A WEBSITE TO NAVIGATE TO
