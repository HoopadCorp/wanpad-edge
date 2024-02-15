# WANPAD Edge Management

## 📖 Documentation

-----

We do have a man page `wanpadctl(8)`. Please read the following manual.

- [Prerequisites](#prerequisites)
- [Install Edge](#install-edge)
  - [Uninstall](#uninstall)
- [Zero-Touch Provisioning](#zero-touch-provisioning)
  - [Provision your device](#provision-your-device)
- [Contributions](#contributions)

## Prerequisites

For WANPAD controller to be able to work with your Device (SDWAN Edge) you need the following requirements:

- **Supported Operating Systems:**

| OS | Architecture |
|---|---|
| Ubuntu:22.04 | x86_64 |
| Armbian 22.02.1 | armv7l |

- **Minimum Hardware:**

| Element | requirement |
|---|---|
| CPU | 2 Cores |
| RAM | 1 GB |
| Storage | 8 GB |
| Network | 2 interfaces |

- This is a System Manager's utility. You **Must** have `root` access to your OS.

- It is recommended to consult [Hoopad](https://github.com/HoopadCorp) technical assistants on the type of the board you choose for the edge devices.

## Install Edge

Login as `root`.

> NOTE: Please just hit `Enter` when you are prompted for a configuration in a pink screen! (linux only)

> NOTE 2: The SSH service will be running on port 24489 after running this script!

```sh
git clone https://github.com/HoopadCorp/wanpad-edge.git
git lfs pull
make install
wanpadctl install
```

Wait for the installation to be completed. If there are any errors, feel free to reach out to _issues_ and inform us or call the tech assistans!

### Uninstall

This should be enough:

```sh
make uninstall
```

## Zero-Touch Provisioning

The Zero-Touch Provisioning on WANPAD requires **Token-based** authentication to add your devices to the controller.

You can obtain a token going through the following menus `Configuration > Devices > Device Tokens`.

### Provision your device

```sh
wanpadctl init
```

You'll be prompted to enter your controller URL and access token:

```
Please Provide the following information:
WANPAD controller URI: <URI HERE>
Your access token: <TOKEN HERE>
```

- **URI format**: `controller.wanpad.ir`

After the prompt return, you should be able to access your device through the controller panel.

- **NOTE:** You can also run the script in **non-interactive** mode, doing:

```sh
wanpadctl <URL HERE> <TOKEN HERE>
```

## 

# Contributions

Any PR(s) are welcomed.
Check the wiki section of Github for more information.
