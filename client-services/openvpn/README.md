&#x202b;


باید برای هر کدام از vpn سرور ها 
(مثلا edge و controller)
فایل .ovpn 
به شکل 
$client_name.ovpn
و
$client_name-edge.ovpn
تعریف شود.
و در مسیر 
/etc/openvpn/
قرار گیرند.

همچنین نام client باید در فایل .env تعریف شود.


برای سرور controller رنج آیپی:

172.30.20.0/24 توسط tun0

و برای سرور edge رنج آیپی :

172.30.10.0/24 توسط tun1

در نظر گرفته شده


