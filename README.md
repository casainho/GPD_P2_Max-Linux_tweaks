__TOC__

= Fan silent =

'''NOTE:''' This was tested on GPD P2 Max on Linux Ubuntu 19.04, running BIOS v0.24 and with fan profile setup on BIOS as silent (other BIOS version and fan profile on BIOS will probably make this not working).

Copy the script file ''[https://github.com/casainho/GPD_P2_Max-Linux_tweaks ec_control.pl]'' to root and make it executable
 sudo cp ec_control.pl /
 sudo chmod a+x /ec_control.pl

Run the script to see it working (the fan should start running slower)
 sudo ec_control.pl gpd_p2_max

Configure Crontab to call ''ec_control.pl'' every 10 seconds	
* Edit crontab config file	
 sudo EDITOR=gedit crontab -e	
* Write at the end of the config file -- NOTE that there should be no space at start of each line and there is a space between each asterisk:<br>	
 * * * * * ( /ec_control.pl gpd_p2_max )	
 * * * * * ( sleep 10 ; /ec_control.pl gpd_p2_max )	
 * * * * * ( sleep 20 ; /ec_control.pl gpd_p2_max )	
 * * * * * ( sleep 30 ; /ec_control.pl gpd_p2_max )	
 * * * * * ( sleep 40 ; /ec_control.pl gpd_p2_max )	
 * * * * * ( sleep 50 ; /ec_control.pl gpd_p2_max )	
* Check crontab to see if the previous lines were saved	
 sudo crontab -l

== Editing temperature values ==

You can edit at top of ''ec_control.pl'' script file.

== How it works ==

There is a Embedded Controller (EC) on the GPD P2 Max just like many other computers and the EC controls various things like the fan. It is possible to read from EC the temperature of the board as also control the amount of rotation of the fan. The ''ec_control.pl'' script file reads the temperature and then define the fan speed based on a predefined values.

The ''ec_control.pl''script is heavily based on this script (many thanks to this!!): https://github.com/RayfenWindspear/perl-acpi-fanspeed/blob/master/fanspeed/acer_ec.pl

= Advanced power management =

Install ''tlp''
 sudo apt-get install tlp

Install ''tlpui'' from here: https://github.com/d4nj1/TLPUI

Now use tlpui to configure the power management settings.

= Check and choose processor speed =

Install [https://extensions.gnome.org/extension/945/cpu-power-manager/ CPU Power Manager] and see the processor speed and also select a desired profile:

[[https://github.com/casainho/GPD_P2_Max-Linux_tweaks/raw/master/cpu_power_manager.png]]

= Check the temperature =

Install ''psensor'' and you will have a widjet on Linux Ubuntu top bar that show the various temperatures as also can plot a graph
 sudo apt-get install psensor

[[https://github.com/casainho/GPD_P2_Max-Linux_tweaks/raw/master/psensor.png]]

= Left Super key as Alt key  =

Install 
 sudo apt-get install gnome-tweaks

Run ''gnome-tweaks'', on ''Keyboard and Mouse'', click on Additional Layout Options:
* Alt/Win key behavior: Left Alt is swapped with Left Win
* Caps lock behavior: Makes caps lock as an additional Super (this way you can use Caps lock as a Super key)

[[https://github.com/casainho/GPD_P2_Max-Linux_tweaks/raw/master/tweaks.png]]

= Optimize screen size =

Install

 sudo apt-get install gnome-tweaks
 sudo apt-get install gnome-shell-extension-autohidetopbar
 sudo apt-get install gnome-shell-extension-pixelsaver

Reboot and then run ''gnome-tweaks'' and enable ''auto hide top bar'' that will make the top bar auto hide. Also enable ''pixel saver'' and windows top bar will disappear but the control buttons will be available on the Ubuntu top bar.

On Ubuntu settings, set the Auto-hide the dock.

In Chrome Internet browser go to Settings -> Appearance -> deselect "Use system style title bar and border".
