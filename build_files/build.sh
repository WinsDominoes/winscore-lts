#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf -y copr enable ublue-os/packages
dnf -y copr enable secureblue/run0edit
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/10/tailscale.repo

# this installs a package from fedora repos
dnf -y install tailscale distrobox uupd podman cockpit samba run0edit git gcc ublue-setup-services


dnf config-manager --add-repo "https://download.docker.com/linux/rhel/docker-ce.repo"
dnf config-manager --set-disabled docker-ce-stable
dnf -y install rsync
dnf -y --enablerepo docker-ce-stable install \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
dnf -y copr disable ublue-os/packages
dnf -y remove PackageKit subscription-manager
#### Example for enabling a System Unit File
systemctl enable brew-setup.service
systemctl enable tailscaled.service
systemctl enable uupd.timer
systemctl enable podman.socket
systemctl enable docker.socket
systemctl enable sshd.service
systemctl enable brew-upgrade.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer
systemctl enable brew-update.service
systemctl --global enable podman-auto-update.timer
systemctl enable rechunker-group-fix.service


source /usr/lib/ublue/setup-services/libsetup.sh

version-script dx-usergroups-lts privileged 1 || exit 0

# Function to append a group entry to /etc/group
append_group() {
	local group_name="$1"
	if ! grep -q "^$group_name:" /etc/group; then
		echo "Appending $group_name to /etc/group"
		grep "^$group_name:" /usr/lib/group | tee -a /etc/group >/dev/null
	fi
}

# Setup Groups
append_group docker


mapfile -t wheelarray < <(getent group wheel | cut -d ":" -f 4 | tr ',' '\n')
for user in "${wheelarray[@]}"; do
	usermod -aG docker "$user"
done
