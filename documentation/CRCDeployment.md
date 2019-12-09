# Running the Cloud Native Starter on OpenShift 4.2

At the time of this writing, OpenShift 4.2 is the latest release of Red Hats OpenShift Kubernetes distribution. This is a Red Hat licensed product, it is not available as free download anywhere.

There is a method that allows to run OpenShift 4.2 on your your own laptop, though. It is called CodeReady Containers (crc) and is the sequel to MiniShift.

`crc` is available for Mac, Linux, and Windows 10 (Pro and Home with Fall Creator's Update), and it uses native virtualization to run OpenShift, namely Hyperkit for Mac, Hyper-V for Windows, and KVM for Linux. Red Hat only supports Red Hat Enterprise Linux, CentOS, and Fedora on the Linux side, Ubuntu et al. users currently have to perform additional configuration on their machines. This is due to different approaches in network name resulution (dnsmasq vs systemd-resolved). You can find information on [CRC Github Issues](https://github.com/code-ready/crc/issues). Hopefully this will be resolved in the future.

To install `crc` follow the official documentation [here](https://cloud.redhat.com/openshift/install/crc/installer-provisioned). You need an Red Hat account to access this page, and you can register for an account on this page if you do not have one. Its free. And you won't be able to install `crc` without an account.

When you sign on to this page, you get access to the official documentation, the download links, and to the 'Pull Secret' and this is the important part: The Pull Secret is personalized to your Red Hat account.




 