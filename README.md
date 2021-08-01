This is intended for a new install only. Please see link below for upgrade instructions.

Special thanks to @willquill for his Omada Ubuntu 16.04 guide :)

# Recommended specs
- Ubuntu 18.04 (20.04 is not supported at this time which appears to be due to lack of MongoDB 3.x support)
- 6+ GB disk (You'll need min 4 GB of free space for MongoDB as found by /u/axel2230 )
- 1+ GB memory

# Install
Connect via SSH or console, run the following command and enjoy a sip of coffee ;)

```
curl -s https://raw.githubusercontent.com/monsn0/omada-installer/main/install-omada-controller.sh | sudo bash
```

Once finished, complete the setup in your web browser. You can reach it at IP:8043 over HTTPS. ie. https://192.168.1.69:8043

You can find your IP by entering `ip a`

<br />

Status of controller: `sudo tpeap status`

Start the controller: `sudo tpeap start`

Stop the controller: `sudo tpeap stop`

# Links
Offical guide: https://www.tp-link.com/en/support/faq/2917/

Guide by @willquill : https://www.reddit.com/r/HomeNetworking/comments/mv1v9d/guide_how_to_set_up_omada_controller_in_ubuntu/ / https://github.com/willquill/omada-ubuntu

Upgrade guide: https://www.tp-link.com/en/omada-sdn/controller-upgrade/
