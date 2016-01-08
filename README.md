# xen-centos-7

* Boot directly from an HTTP mirror (e.g. http://mirror.rackspace.com/CentOS/7.2.1511/os/x86_64/). Specify the boot parameters:
console=hvc0 utf8 nogpt noipv6 ks=https://github.com/grafke/xen-centos-7-kickstart/blob/master/cent70-server.ks
Note: you may have to host the kickstart script on your own HTTP server, since occasional issues, possibly SSL-related, have been observed with netboot installers being unable to fetch the raw file through GitHub.

* use install_new_vm.sh to install a new VM from a template

TO-DO:

fix grub 
crashkernel=auto --> crashkernel=0M-2G:128M,2G-6G:256M

