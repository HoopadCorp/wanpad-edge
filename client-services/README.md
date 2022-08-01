&#x202b;



# مقدمه

این دایرکتوری شامل سرویس های customized شده برای 
client-side سرویس WANPAD SD-WAN میباشد و این
داکیومنت جهت راهنمایی در راه اندازی, به کار گیری و معرفی این سرویس ها میباشد.

# چکیده
- [معرفی سرویس ها](#معرفی-سرویس-ها)
- [راه اندازی سرویس ها](#راه-اندازی-سرویس-ها)


### معرفی سرویس ها

سرویس های تهیه شده اصطلاحا systemd-based بوده و توسط systemds مدیریت و اجرا میشوند.
در ادامه با وظیفه هر سرویس آشنا شده و به جزئیاتی مانند `Dependency` های آن سرویس میپردازیم.

- سرویس ca-recognition :

این سرویس با معرفی فایل ca.crt که مربوط به `WANPAD CA` یعنی CA AUTHORITY که به صورت لوکال برای پروژه WANPAD راه اندازی کردیم باعث میشود که سرویس های دیگر که نیاز به ارتباط TLS/SSL دارند بتوانند به certificate های صادر شده توسط این CA اعتماد کنند.

این سرویس, نیازی به سرویس پیشنیاز ندارد.

- سرویس wanpad-controller-oob :

این سرویس برای ایجاد برقراری ارتباط توسط openvpn client با openvpn سرور در 
سرور controller  استفاده میشود.

این سرویس برای اجرا شدن نیاز دارد تا سرویس نتورک دیوایس active باشد.

Requires=network-online.target network.target

- سرویس plug&play :

همان طور که از نان این سرویس مشخص است, جهت اتصال اتوماتیک دستگاه wanpad-client به کنترلر, از این سرویس استفاده میشود.

سرویس های پیشنیاز این سرویس عبارتند از :

1. network.target
2. wanpad-controller-oob.service
3. network-online.target

- سرویس wanpad-node-exporter : 

این سرویس برای expose کردن metric های مربوط به مانیتورینگ هر دیوایس استفاده میشود.

پیشنیاز ها :

1. network-online.target
2. network.target



### راه اندازی سرویس ها

برای راه اندازی سرویس ها لازم است که فایل های `*.service` آن ها را در مسیر `/etc/systemd/system` قرار دهید.

به علاوه آن فایل های اجرایی هر سرویس که شامل اسکریپت ها و فایل های `env` آن ها میباشند باید در جای صحیح خود قرار گیرند.
مسیر مورد نظر در فایل `*.service` و دایرکتیو `WorkingDirectory`
مشخص شده است که به این صورت که هر سرویس درون فولدری مشخص و در ادامه مسیر `/etc/wanpad/` 
قرار میگیرد.


کامند های زیر به سادگی مراحل بالا را برایتان انجام خواهند داد:

~~~
cd
apt update -y
apt install -y git openvpn python3-pip wireguard snmpd libqmi-utils udhcpc
git config --global http.sslVerify false
git clone https://gitlab.wanpad.ir/wanpad/wanpad_os.git
mkdir /etc/wanpad/
ln -sf ~/wanpad_os/client-services/*/*.service /etc/systemd/system/
ln -sf ~/wanpad_os/client-services/* /etc/wanpad/
~~~

قدم بعدی enable کردن این سرویس ها میباشد که نتیجه آن اجرا شدن این سرویس ها بعد از هر boot سیستم میباشند. 

به این ترتیب :
~~~
sudo systemctl daemon-reload
# for i in `ls /etc/wanpad/*/wanpad*.service  | xargs` ; do systemctl enable $i ; done
# or
for i in `ls /etc/systemd/system/wanpad-* | sed 's|/etc/systemd/system/||g'` ; do systemctl enable $i ; done
~~~

برای اجرای استارت سرویس ها :

~~~
for i in `ls /etc/systemd/system/wanpad-* | sed 's|/etc/systemd/system/||g'` ; do systemctl start $i ; done
~~~
