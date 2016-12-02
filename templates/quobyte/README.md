quobyte
=======

Turn your ephemeral toys into durable, stateful applications.

* Fake Device Deployment

For testing purposes, the root filesystem may be used for the registry, metadata, and data devices. This is for testing purposes only, as performance will be poor.

To make use of this deployment model, simply create your Rancher hosts with appropriately-sized root devices. A minimum size of `50GB` is recommended. The template will take care of creating fake devices.

* Dedicated Device Deployment

In a real production deployment, you will want to make use of dedicated devices. It is your responsibility to create the filesystem (`ext4` is recommended) and mount the devices (`/etc/fstab` entries are recommended to allow server reboots).

Assuming you are using the default device path `/mnt`, you want to mount your devices at the following locations:

* `/mnt/registry` on each host that will run a registry node. If your environment has more hosts than registry nodes, you should pin the nodes by setting the label `quobyte=registry` on hosts with registry devices.
* `/mnt/metadata` on each host that will run a metadata service. We schedule this service globally, so no special labelling is required - services without a device will remain idle.
* `/mnt/data` on each host that will run a data service. We also schedule this service globally.

It would be viable to mount multiple devices to a single host, which may make sense if building on bare metal. Mount the devices within their respective folders, such as `/mnt/metadata/1`, `/mnt/metadata/2`, etc. Only one registry device per host will be used, others will be only be used in the event of a hardware failure.

* Using a Deployment with Multiple Environments

A client is necessary to make use of Quobyte volumes. By default, we schedule client nodes globally with the Quobyte deployment. If you want to make use of a deployment in other environments, launch the `Quobyte Client` template into each desired environment.