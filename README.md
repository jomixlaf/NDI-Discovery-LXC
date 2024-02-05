# NDI-Discovery-LXC
Script to commission an NDI discovery Server inside an LXC container.

/!\ I am not a programmer /!\
I learned myself here and there and might be better way to do stuff. 
Plus my english is not perfect !

I wrote this script to deploy quickly inside an LXC containe Debian 11 on a Proxmox server.

The way to use once your LXC is created you don't need to update anything this script does everythings. 
What does it do. 

Update and upgrade the Debian installation. 
Install Apache2, Iperf3, and latest NDI5 Discovery Server via the SDK.
Create services to autorun after boot the mentionned pieces.
That's it. 

Because I live in Montreal I Commented with # the script so you can set your own Timezone.

Tested on Debian with NDI 5.6

1 step
type in the terminal --> wget https://raw.githubusercontent.com/jomixlaf/NDI-Discovery-LXC/main/NDI-Discovery-Server-Install.sh
then ---> chmod +x
then wait... Then you must read the EULA incorporated in the NDI SDK we just download within the script. 

Then that's it ! 


The output of the functinnal discovery server can be seen thru your web browser with his IP address /ndi-discovery-log.txt
if you run this machine for ever like I do every 00:00 it restart the NDI Discovery Service and create a new ndi-discovery-log.txt
The previous data can be seen in the folder located here /var/www/html/ndi-discovery-log-all/ 
This is very usefull when troubleshooting NDI Connections. now the time seen in the log will always correspond to real time data.


I hope you have with this like I do as I said, not a programmer at all I learded everything by myselft thanks the internet ! 

I may update or add feature in the future as well will see. Give me a hint if something is not working or need more info. Thanks for reading. 
