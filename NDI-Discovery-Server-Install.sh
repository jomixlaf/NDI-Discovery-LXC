#!/bin/bash
export PAGER=cat

clear                         #clear content of the screen

############################## Startup script ##############################

echo "################################"
echo "### Immersive Design Studios ###"
echo "################################"
echo
echo Update and Upgrade Debian, then install iperf3, apache2 and curl
apt update && apt upgrade -y
apt install iperf3 -y                     # needed for test ethernet bandwith
apt install apache2 -y                    # needed for NDI-Discovery-log remotely visible
apt install curl -y                       # probably to be deprecated if I automate this script entirely 


timedatectl set-timezone America/Toronto  # Set local time

echo "empty /etc/motd and adjust /etc/issue"
rm /etc/motd && touch /etc/motd           # delete original file and create an empty one

cat > /etc/issue << "EOD"                 # create a custom file with role, and IP address
Debian GNU/Linux 11 \n \4 \l

################################
##### NDI Discovery Server #####
################################
### Immersive Design Studios ###
################################

EOD

cat > /root/canvas-logo.txt << "EOL"
                                                                                                                        
                                                                                                                        
         .!5#&@P                 JP5P.        .5555.      ^P5P^  7P5P7        YP5P:    .P5PJ           ^JPBBBGY~.       
       .G@@@@@@P                J@@@@&        :@@@@@^     J@@@J  :@@@@:      J@@@&     &@@@@J        ?@@@@&&&@@@@P      
      7@@@@B!.                 ~@@@@@@G       :@@@@@@J    ?@@@J   7@@@#     .@@@@.    G@@@@@@^      ~@@@#     Y@@@5     
     ~@@@@^                   .@@@P^@@@J      :@@@@@@@G   ?@@@J    G@@@?    B@@@!    J@@@^P@@@.     :@@@&7.    ....     
     #@@@7                    #@@&  Y@@@^     :@@@#.&@@&. ?@@@J     &@@@.  7@@@P    ~@@@Y  &@@#      :G@@@@@&G?:        
     #@@@7           .@@@@.  P@@@^   #@@@.    :@@@#  G@@@~?@@@J     :@@@G .@@@&    .@@@#   ~@@@P        ^?G#@@@@&J      
     ~@@@@^         .#@@@P  7@@@@&&&&@@@@#    :@@@#   ?@@@&@@@J      J@@@~P@@@:    #@@@@&&&&@@@@7   ^~~^     .P@@@5     
      7@@@@B!.   .~P@@@@G  :@@@&GBBBBG#@@@P   :@@@#    ^@@@@@@J       B@@@@@@?    P@@@#GBBBBG&@@@:  B@@@?     7@@@B     
       .P@@@@@@@@@@@@@#~  .@@@@:       B@@@?  :@@@&     .#@@@@J       .@@@@@G    ?@@@B       :@@@@.  5@@@@&&&@@@@B.     
          ~5B&@@@&#P7.    ~P55!        .555Y  .555?       ?55P^        ^5555     Y555.        ~55P~    ^?PGBBGY7.        
          
                                                                                                                        
                                                                                                                        
EOL

############################## Startup script ##############################

############################## NDI Installation script ##############################

echo "Please wait while downloading latest NDI SDK V5..."
sleep 3

if [ ! -f "Install_NDI_SDK_v5_Linux.tar.gz" ]; then
    wget https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz
fi
if [ ! -f "Install_NDI_SDK_v5_Linux.sh" ]; then
    tar -xvf Install_NDI_SDK_v5_Linux.tar.gz
fi
if [ ! -f "/NDI SDK for Linux/bin/x86_64-linux-gnu/ndi-directory-service" ]; then
  echo "y" | ./Install_NDI_SDK_v5_Linux.sh
fi

sleep 1

echo "Clean Directory"
rm Install_NDI_SDK_v5_Linux.tar.gz
rm Install_NDI_SDK_v5_Linux.sh
mv "/root/NDI SDK for Linux/bin/x86_64-linux-gnu/ndi-directory-service" /root/ndi-discovery-server
rm -r 'NDI SDK for Linux'
echo done

sleep 1

echo "Create the script for NDI Discovery"
cat > /root/ndi-discovery-server-script.sh << "EOF"
#! /bin/bash
now=$(date +"%F-T%H:%M:%S:%p")
logo="/root/canvas-logo.txt"
rm       /var/www/html/ndi-discovery-log.txt
touch    /var/www/html/ndi-discovery-log.txt
mkdir -p /var/www/html/ndi-discovery-log-all
echo "Immersive Design Studios" "$now" > /var/www/html/ndi-discovery-log.txt
echo " " >> /var/www/html/ndi-discovery-log.txt
printf "%s" "$(<$logo)" >> /var/www/html/ndi-discovery-log.txt
echo " " >> /var/www/html/ndi-discovery-log.txt
clear
echo
echo "=== Immersive Design Studios ===" #| sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n'
echo
/root/ndi-discovery-server\
| tee -a /var/www/html/ndi-discovery-log-all/ndi-discovery-log-"$now".txt /var/www/html/ndi-discovery-log.txt\
| tail -F /var/www/html/ndi-discovery-log.txt

EOF

# Time to create Service
clear
IS_ACTIVE=$(systemctl is-active $ndi-discovery-server.service)
if [ "$IS_ACTIVE" == "active" ]; then
echo "Service is running"
echo "Restarting service"
systemctl restart $ndi-discovery-server.service
echo "Service restarted"

else
# create service file
echo "Creating NDI Discovery Service"
cat > /etc/systemd/system/ndi-discovery-server.service << "EOT"
[Unit]
Description=NDI Discovery Server
After=multi-user.target

[Service]
ExecStart=/usr/bin/bash /root/ndi-discovery-server-script.sh
Restart=always
RestartSec=5s
Type=simple

[Install]
WantedBy=multi-user.target

EOT

fi

cat > /etc/systemd/system/iperf3.service << "EOS"
[Unit]
Description=iperf3 in server mode after booting with auto restart if fail
After=multi-user.target

[Service]
ExecStart=iperf3 -s
Restart=always
RestartSec=5s
Type=simple 

[Install]
WantedBy=multi-user.target

EOS

clear

sleep 1

echo "Enable and start services"
systemctl daemon-reload
systemctl enable ndi-discovery-server.service
systemctl enable iperf3.service
systemctl start ndi-discovery-server.service
systemctl start iperf3.service
echo "Service Started"
sleep 2
clear
exit 0