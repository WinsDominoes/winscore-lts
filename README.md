# Purpose

Have a ready made solution for bootc homelab

# ISO Building Process

First clone this repo, then enter into disk_config directory and run `just`, the ISO should be made in a new output folder.

*Note: Make sure you have just installed on your system. If you are own SELinux and it fails to build, make sure `osbuild-selinux` package is present as well*

# Issues

There are probably a lot but the most notable one being docker group not being added by defualt