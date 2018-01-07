# packer-template-ubuntu1604-ansible-proxy

[Packer](https://www.packer.io/) template for Ubuntu Server 16.04 [Vagrant](https://www.vagrantup.com/) boxes, capable of Ansible provisioning behind a proxy. Example playbook for deploying Docker with proxy settings has been provided.

## Usage

To build Hyper-V only:

	$  packer build -only=hyperv-iso .\ubuntu1604.json

To build QEMU only:

	$ packer build -only=qemu .\ubuntu1604.json

## Notes
This template has been created in order to resolve problems with provisioning Ubuntu Server 16.04 behind a proxy. Keep in mind that:
- If you need to configure apt-get proxy from Packer template, you cannot use `choose-mirror-bin mirror/http/proxy string addr`. It is not possible to customize `addr` in this case.
- Using `choose-mirror-bin mirror/http/proxy string addr` in preseed.cfg has different impact compared to using `mirror/http/proxy=addr` from boot parameters. The latter also affects downloading preseed.cfg from http server (seems like a debconf bug).
- Downloading preseed.cfg from `preseed/url` is sensitive to proxy settings inherited from `mirror/http/proxy` (which seems contrary to description of this parameter). Fortunately I have discovered that setting `no_proxy={{ .HTTPIP }}` environment variable from boot parameters is enough to force no proxy for wget in order to communicate with Packer http server.
- There is a limitation for Boot Options length that can be used when installing Ubuntu using QEMU. This means that there may be not enough place to type all commands connected with keyboard settings when using proxy, but you can use `auto-install/enable=true` and feed them from preseed.cfg
- For Hyper-V, if you would like to use Gen. 2 machines, you can't use floppies (https://technet.microsoft.com/en-us/library/dn282285(v=ws.11).aspx), therefore you have to stick to `preseed/url` method for providing preseed.cfg.
- For Hyper-V, it is important to perform `d-i preseed/late_command string in-target apt-get install -y --install-recommends linux-virtual-lts-xenial linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial;`, directly in preseed.cfg, *BEFORE* any provisioner runs. These packages are needed in order to discover IP address of VM properly so that Packer can connect via SSH. Otherwise it will be waiting for IP address forever, more details can be found in "Notes" in https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
- For shell provisioners and propagation of proxy settings, use:
```
"environment_vars": [
    "FTP_PROXY={{ user `ftp_proxy` }}",
    "HTTPS_PROXY={{ user `https_proxy` }}",
    "HTTP_PROXY={{ user `http_proxy` }}",
    "NO_PROXY={{ user `no_proxy` }}",
    "ftp_proxy={{ user `ftp_proxy` }}",
    "http_proxy={{ user `http_proxy` }}",
    "https_proxy={{ user `https_proxy` }}",
    "no_proxy={{ user `no_proxy` }}"
  ]
```
- For ansible-local provisioner use:
```
"extra_arguments": [
    "--extra-vars",
    "{'\"http_proxy\":\"{{ user `http_proxy` }}\", \"https_proxy\":\"{{ user `https_proxy` }}\", \"no_proxy\":\"{{ user `no_proxy` }}\", \"ftp_proxy\":\"{{ user `ftp_proxy` }}\"}'"
  ]
  ```
Then handle these variables appropriately in playbook, set environment variables, etc.
- In case of ansible-local there are problems when specifying inventory_groups: even though connection type passed to ansible is "local", it gets ignored and regular SSH connection is used. This causes problems due to unauthorized key for passwordless login to localhost. As a workaround you have to specify inventory_file with ansible_connection specified explicitly, for example:
```
[ubuntu]
127.0.0.1 ansible_connection=local
```