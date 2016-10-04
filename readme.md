Installation notes for JAGS and Matjags in Windows

## Step 1: Install JAGS

* Visit the jags development site at [http://www-ice.iarc.fr/~martyn/software/jags/](http://www-ice.iarc.fr/~martyn/software/jags/)
and follow instructions to install the windows version of JAGS.

* Note that MATJAGS was tested on version 3.0.0

## Step 2: Place the JAGS bin directory in the Windows path

* The directory where the JAGS executable is stored should be placed in the windows path.

* In Windows 7, go to Control Panel,  System and Security, System and click on "Advanced System Settings"
followed by "Environment Variables" Under System variables, click on Path, and add the jags path to the string.
This could look something like ``"C:\Program Files\JAGS\JAGS-3.0.0\x64\bin"`` or whatever the path is.

* If you have Matlab up and running already, quit matlab and start again to make sure that the new path is used by Matlab.

* You can test whether the system path is updated by starting a dos prompt window (type "cmd" in the "search programs and
files" box when you click the windows start button and type in "JAGS". If the path is updated, it should start the JAGS program).

## Step 3: Test MATJAGS

* Run one of the example scripts for Matjags. It might be helpful if the folder where MATJAGS is stored
is placed on the Matlab path. To change the matlab path in Windows 7, you'll have to run Matlab as an administrator
(right click the matlab program icon, and choose "run as administrator")  
