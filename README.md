# Omada Installer
A script to perform a new install of the TP-Link Omada Software Controller on Ubuntu.

This script was created due to convoluted or outdated guides on the web for installing the Omada Controller. The goal was to create a clean, simple script that anyone can run for ease of deployment.

Special thanks to @willquill for his Omada Ubuntu 16.04 guide :)

# Supported releases
- Ubuntu 22.04 LTS
- Ubuntu 20.04 LTS
- Ubuntu 18.04 LTS
- Ubuntu 16.04 LTS

# Recommended specs
- Ubuntu 20.04 LTS
- 8+ GB disk ( You'll need min 4 GB of free space for MongoDB as found by /u/axel2230 )
- 1+ GB memory

Ubuntu 20.04 is still the recommended release as MongoDB 4.4 (required version for Omada Controller) does not offically support 22.04 and therefore the installer will perform some workarounds to install on 22.04. That being said, it has been confirmed to work without any apparent issues.

# Install
Connect via SSH or console, run the following command and enjoy a sip of coffee ;)

```
curl -s https://raw.githubusercontent.com/monsn0/omada-installer/main/install-omada-controller.sh | sudo bash
```

Once finished, complete the inital setup wizard in your web browser via the URL in the final output.

### Usage
To manage the controller service, use the `tpeap` script as root.
The script is located as a symlink in `/usr/bin`

```
usage: tpeap help
       tpeap (start|stop|status|version)

help       - this screen
start      - start the service(s)
stop       - stop  the service(s)
status     - show the status of the service(s)
version    - show the version of the service(s)
```

# Links
Offical guide: https://www.tp-link.com/us/support/faq/3272/

Guide by @willquill : https://www.reddit.com/r/HomeNetworking/comments/mv1v9d/guide_how_to_set_up_omada_controller_in_ubuntu/ / https://github.com/willquill/omada-ubuntu

Upgrade guide: https://www.tp-link.com/en/omada-sdn/controller-upgrade/
