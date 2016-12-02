quobyte-aws
===========

**NOT READY FOR USE** For a production-grade Quobyte installation with fault tolerance, use the `Quobyte` catalog entry.

Automated setup of a fault-tolerant Quobyte server installation in AWS using EBS block devices.

# Prerequisites

* Rancher EBS plugin, v0.6.0 or later

# Limitations

Only standalone (single-server) deployments are supported at the time of writing, due to a limitation in the EBS volume plugin WRT services of scale > 1.

EBS volume type and size are also hard-coded to the following values:
* Registry - gp2, 1GB
* Metadata - gp2, 2GB
* Data - gp2, 10GB

