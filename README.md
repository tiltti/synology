# Synology Scripts
Scripts for Synology DSM.

### Auto VPN Reconnect
Perhaps the most annoying part of the otherwise brilliant DSM for me is the lack of automatically reconnecting VPN in case of it drops. There are options to cut all traffic if VPN is not available, but not a simple option to try to reconnect - and if fails, retry (and send an alert, which would be nice to implement in case retry fails, too).

This script is for OpenVPN only, but I'll add other protocols as well if you need them.

#### Installation

You need to variables to be entered into the script. First one is VPN **conf_id** for the script, which is not available in the GUI of DSM. Second one is **conf_name** which you will find from the DSM GUI.

Getting the VPN configuration id (conf_id):
```
# ps -ef|grep client_o
root       616     1  0 13:18 ?        00:00:00 /usr/sbin/openvpn --daemon --cd /usr/syno/etc/synovpnclient/openvpn --config client_o1390502566 --writepid /var/run/ovpn_client.pid
root       645     1  0 13:18 ?        00:00:00 /usr/sbin/openvpn --daemon --cd /usr/syno/etc/synovpnclient/openvpn --config client_o1390502566 --writepid /var/run/ovpn_client.pid
admin     2859 16399  0 13:21 pts/8    00:00:00 grep --color=auto client_o
```
In this case your conf_id would be **o1390502566**, and note that the first is letter o which is also needed. The also needed conf_name is the name of the VPN configuration in your DSM GUI, so check it from there.

Get the script and place it for instance into root's directory in /root:

Example script using my configuration:

```sh
conf_id='o1390502566'
conf_name='PIAOpenVPN'

rundate=`date`

if echo `ifconfig tun0` | grep -q "00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00"
then
        echo "$rundate: VPN is running"
    else
        echo "$rundate: Uh, oh - VPN seems to be down :( Reconnecting...)"
        echo conf_id=$conf_id > /usr/syno/etc/synovpnclient/vpnc_connecting
        echo conf_name=$conf_name >> /usr/syno/etc/synovpnclient/vpnc_connecting
        echo proto=openvpn >> /usr/syno/etc/synovpnclient/vpnc_connecting
        /usr/syno/bin/synovpnc reconnect --protocol=openvpn --name=$conf_name
fi
exit 0
```

**Please note that you have to replace the variables mentioned above with your own configurations!**

Give the script executable privileges if you already didn't by:
```
# sudo chmod +x /root/openVPNreconnect.sh
```

You can test the script and see that it works. Also check from the DSM GUI side that it shows the VPN as connected.

````
# sudo /root/openVPNreconnect.sh
````
In case the VPN is running and everything is okay, the output should be:
```
Everything OK: VPN seems to be running...
```

If not, it should reconnect automagically:
```
tun0: error fetching interface information: Device not found
get arguemnt protocol: openvpn
get arguemnt name: PIAOpenVPN
Reconnect [PIAOpenVPN] ... done
```

Next you'll need to access the DSM via ssh in order to place the script into the filesystem and modify crontab to get it running for example in every 5 minutes.

Example crontab (in /etc/crontab):

```
*/5	*	*	*	*	root	/root/openVPNreconnect.sh
```

Since Synology doesn't log crontab executables by default. This is probably since BusyBox Synology is using logging to syslog by default, but then looking at the process list syslog daemon is run with -S parameter (Smaller logging output) that seems to remove the logging altogether. To go around this you can redirect the script output to a logfile of your choosing if you want to follow up that the script is working.

Doing it in crontab is the easiest. The example logs to /var/log/vpn_reconnect.log obvously:

```
*/5	*	*	*	*	root	/root/openVPNreconnect.sh >> /var/log/vpn_reconnect.log
```

**Please note that the spaces in between need to be tabs, not spaces, or DSM will remove the config considering it invalid! And do not touch the lines you are not sure what they do :)**

Another test would be to disconnect this from the DSM GUI side and see that it reactivates after ~5 minutes. The downside is that there is no way to permanently deactivate the automatic VPN reconnection from the GUI side anymore, but you have to comment out the crontab if such a need arises. If anyone has suggestions how to do this otherwise, let me know.
