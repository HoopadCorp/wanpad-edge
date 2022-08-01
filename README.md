# WANPAD Edge Management

## 📖 Documentation
-----
- [Prerequisites](#Prerequisites)
- [Zero-Touch Provisioning](zero-touch-provisioning)
  - [Install Edge Dependencies](#install-edge-dependencies)
  - [Provision your device](#provision-your-device)
- [Contributions](#Contributions)


## Prerequisites

For WANPAD controller to be able to work with your Device you need the following requirements:

- **Supported Operating Systems:**

| OS | Architecture |
|---|---|
| Ubuntu:20.04 | x86_64 |
| Armbian 22.02.1 | armv7l |


- **Minimum Hardware:**

| Element | requirement |
|---|---|
| CPU | 2 Cores |
| RAM | 1 GB |
| Storage | 8 GB |
| Network | 2 interfaces |


- You **Must have** `root` access to the device you want to add to your organization.


- It is recommended to consult _WANPAD_ technical assistants on the type of the board you choose for the edge devices.



## Zero-Touch Provisioning

The Zero-Touch Provisioning on WANPAD requires Token-based authentication to add your devices to the controller.

You can obtain a token doing `User Profile > Tokens > add token` and set the permission for the token to `add device`.

### Install Edge Dependencies

~~~
cd /root/
git clone https://github.com/HoopadCorp/wanpad-edge.git
cd ./wanpad-edge/installation/
./install.sh
~~~

Wait for the installation to be completed. If there are any errors, feel free to reach out to _issues_ and inform us or call the tech assistans!

### Provision your device

~~~
./ztp-init.sh
~~~

You'll be prompted to enter your controller URL and access token:

~~~

Please Provide the following information:

WANPAD controller URI: <URL HERE>
Your access token: <TOKEN HERE>
~~~

After the prompt return, you should be able to access your device through the controller panel.

- **NOTE:** You can also run the script in **non-interactive** mode, doing:

~~~
./ztp-init.sh <URL HERE> <TOKEN HERE>
~~~


# Contributions
Any PR(s) are welcomed.
