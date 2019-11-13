# Copyright (c) 2002-2019 by Symas Corporation
# All rights reserved.

# Configure VirtualBox Demo Environment

## Copy all files from the flash drive provided to your computer.

## Install VirtualBox

1. From the files copied to your computer, double-click on the VirtualBox install file for your platform
2. Follow the prompts to install VirtualBox

## Create New VM

1. Launch VirtualBox

2. Click on New button:

<img style="border:5px solid black" src="images/01-new.png" height="60">

3. Create a name for your virtual machine, select "Linux," select "Other 64-bit," then click Continue:

<img src="images/01-name-operating-system.png" height="206" border="1">

4. Change Memory size to 1024mb by typing in the size box or using the slider tool, then click Continue:

<img src="images/05-memory.png" height="143" border="0">

5. Keep the selection of "Create a virtual hard disk now," then click Create:

<img src="images/10-harddisk.png" height="106">

6. Keep the selection of "VDI (VirtualBox Disk Image)," then click Continue:

<img src="images/15-disktype.png" height="130">

7. Keep the selection of "Dynamically allocated," then click Continue:

<img src="images/20-dynamic-alloc.png" height="70">

8. Change the virtual hard disk size from 8.00 to 20, either by typing directly or using the slider bar, then click Create:

<img src="images/25-diskname-disksize.png" height="240">

9. Once the VM has been created, select the VM to highlight it, then click the start button:

<img src="images/30-start.png" height="240">

10. The next step allows you to connect the Centos 7 image (provided on the flash drive) to this VM. Click on the folder icon next to the dropdown,
and navigate to the location of the Centos 7 image, select it, then click the Start button:

<img src="images/35-select-image.png" height="65">

11. Click Enter to start the install of Centos 7. You can click on Settings in the VirtualBox toolbar, click on "Display", then set the scale factor
to 250% to make the screen larger:

<img src="images/40-set-screensize.png" height="275">

12. The install process will pause on the language selection screen. Select your language and click Continue:

<img src="images/45-set-language.png" height="500">

13. On the installation summary screen, the installation destination has to be specified, so click on Installation Destination:

<img src="images/50-install-destination.png" height="500">

14. On the Device Selection screen, click on the ATA VBOX HARDDISK icon:

<img src="images/55-install-destination.png" height="250">

15. Installation Source will now say "Automatic partioning selected":

<img src="images/53-install-destination.png" height="275">

16. Next step will be to set up the network configuration, so click on "Network & Host Name":

<img src="images/58-network-setup.png" height="275">

17. Click the toggle switch to enable network connectivity, then click Done:

<img src="images/58-network-config.png" height="275">

18. Click Begin Installation:

<img src="images/60-begin-installation-update.png" height="275">

19. While the installation of Centos 7 continues, set the root password and set up a first user account:

<img src="images/65-set-root-pw.png" height="100">

20. After the installation has been completed, you need to reboot the VM:

<img src="images/70-reboot.png" height="100">

21. This brings you to the login screen:

<img src="images/75-login.png" height="100">

22. To shutdown your new VM, click on Machine in the toolbar, then ACPI-Shutdown:

<img src="images/80-shutdown.png" height="100">
