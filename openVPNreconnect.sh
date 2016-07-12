
# Thanks aelveborn@github for making the first version. 
#
# You need two parameters:
# 1) conf_id: you'll get this by running ps -ef|grep client_o and copy pasting the o123456789 to the script below
# as far as I know there is no way to get this info (easily) from the GUI, so you'll need the shell access.
# 2) conf_name: replace the YOUR_VPN_NAME with your DSM GUI name for the connection.

if echo `ifconfig tun0` | grep -q "00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00"
then
        echo "Everything OK: VPN seems to be running..."
	else
        echo conf_id=o1390502566 > /usr/syno/etc/synovpnclient/vpnc_connecting
        echo conf_name=YOUR_VPN_NAME >> /usr/syno/etc/synovpnclient/vpnc_connecting
        echo proto=openvpn >> /usr/syno/etc/synovpnclient/vpnc_connecting
        /usr/syno/bin/synovpnc reconnect --protocol=openvpn --name=YOUR_VPN_NAME
fi
exit 0
