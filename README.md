# Omada Installer
A script to perform a new install of the TP-Link Omada SDN Controller software on Ubuntu 16.04, 18.04 or 20.04.

Please see link below for instructions on upgrading from 3.2.14 or below.
For upgrading from 4.1.4 or later, you _should_ be able to download the latest version and upgrade using dpkg.
However, perform at your own risk and **be sure to take a backup!**

Special thanks to @willquill for his Omada Ubuntu 16.04 guide :)

# Recommended specs
- Ubuntu 20.04
- 8+ GB disk ( You'll need min 4 GB of free space for MongoDB as found by /u/axel2230 )
- 1+ GB memory

# Install
Connect via SSH or console, run the following command and enjoy a sip of coffee ;)

```
curl -s https://raw.githubusercontent.com/monsn0/omada-installer/main/install-omada-controller.sh | sudo bash
```

Once finished, complete the setup in your web browser via the URL in the final output.

<br />

Status: `sudo tpeap status`

Start: `sudo tpeap start`

Stop: `sudo tpeap stop`

# Links
Offical guide: https://www.tp-link.com/us/support/faq/3272/

Guide by @willquill : https://www.reddit.com/r/HomeNetworking/comments/mv1v9d/guide_how_to_set_up_omada_controller_in_ubuntu/ / https://github.com/willquill/omada-ubuntu

Upgrade guide: https://www.tp-link.com/en/omada-sdn/controller-upgrade/
