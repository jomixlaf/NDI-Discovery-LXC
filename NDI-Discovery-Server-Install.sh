#!/bin/bash
export PAGER=cat
CHECK_MARK=" \xe2\x9c\x85"
CHECK_CROSS=" \xe2\x9d\x8c"

ping -c 1 8.8.8.8 &> /dev/null && echo -e "\\r${CHECK_MARK} Internet working" || echo -e "\\r${CHECK_CROSS} Internet not working"

sleep 5

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

sleep 1

echo "Setting Montreal timezone" 
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

# Create CANVAS logo in a file
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

echo "Downloading latest NDI SDK V5..."
sleep 1
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
cat > /root/ndi-discovery-server-script.sh <<"EOF"
#! /bin/bash
now=$(date +"%F-T%H:%M:%S:%p")
logo="/root/canvas-logo.txt"
rm       /var/www/html/ndi-discovery-log.txt
touch    /var/www/html/ndi-discovery-log.txt
mkdir -p /var/www/html/ndi-discovery-log-all
printf "%s" "$(<$logo)" >> /var/www/html/ndi-discovery-log.txt
echo " " >> /var/www/html/ndi-discovery-log.txt
echo " " >> /var/www/html/ndi-discovery-log.txt
echo " " >> /var/www/html/ndi-discovery-log.txt
echo "Immersive Design Studios" "$now" >> /var/www/html/ndi-discovery-log.txt
echo " " >> /var/www/html/ndi-discovery-log.txt
clear
echo
echo
/root/ndi-discovery-server | tee -a /var/www/html/ndi-discovery-log-all/ndi-discovery-log-"$now".txt /var/www/html/ndi-discovery-log.txt

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
# create service for the NDI Discovery Server
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
Description=start iperf3 in server mode at boot
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
sleep 1
if (systemctl -q is-active iperf3.service)
        then
                echo -e " \xe2\x9c\x85  iperf3 is running."
        else 
                echo -e " \xe2\x9d\x8c  iperf3 is not running"
fi
sleep 1
if (systemctl -q is-active apache2.service)
        then
                echo -e " \xe2\x9c\x85  Apache2 is running."
        else 
                echo -e " \xe2\x9d\x8c  Apache2 is  not running"
fi
sleep 1
if (systemctl -q is-active ndi-discovery-server.service)
        then
                echo -e " \xe2\x9c\x85  NDI Discovery Server is running."
        else 
                echo -e " \xe2\x9d\x8c  NDI Discovery Server is not running"
fi
sleep 0.5 
echo "congrats"
