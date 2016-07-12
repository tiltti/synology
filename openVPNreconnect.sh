
# You need the following parameters:
# conf_id: you'll get this by running ps -ef|grep client_o and copy pasting the o123456789 to the script below
# as far as I know there is no way to get this info (easily) from the GUI, so you'll need the shell access.
# conf_name: replace the YOUR_VPN_NAME with your DSM GUI name for the connection.

conf_id='o123456789'
conf_name='YOUR_VPN_CONFIG_NAME'

# Get the running date to be shown, mostly for logging purposes.
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
