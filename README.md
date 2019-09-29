# Fan control

Copy the script file ¨ec_control.pl¨ to root and make it execuatble:



WIP



Place the script files on /
Make them executable: sudo chmod a+x scrit_file

Call them on Crontab every 10 seconds:

sudo gedit /etc/crontab

inside tge crontab file, place:

* * * * * ( /gpd_p2_max-fan_controller.sh > ~/gpd_p2_max-fan_controller-log.txt )
* * * * * ( sleep 10 ; /gpd_p2_max-fan_controller.sh > ~/gpd_p2_max-fan_controller-log.txt )
* * * * * ( sleep 20 ; /gpd_p2_max-fan_controller.sh > ~/gpd_p2_max-fan_controller-log.txt )
* * * * * ( sleep 30 ; /gpd_p2_max-fan_controller.sh > ~/gpd_p2_max-fan_controller-log.txt )
* * * * * ( sleep 40 ; /gpd_p2_max-fan_controller.sh > ~/gpd_p2_max-fan_controller-log.txt )
* * * * * ( sleep 50 ; /gpd_p2_max-fan_controller.sh > ~/gpd_p2_max-fan_controller-log.txt )

Verify that script is being called:
cat gpd_p2_max-fan_controller-log.txt 

You can also call manually the script:
sudo gpd_p2_max-fan_controller-log.txt
