## 0.1.1 (Unreleased)

* Do not create empty Packer namespace entries if the Racker template does not contain the namespace.
* Added the ability to set the knockout prefix from the command line.
* Changed default knockout prefix from '--' to '~~' as it conflicted with certain Virtualbox builder keys.

## 0.1.0 (2014-02-23)

* Initial public release

## 0.0.3 (Internal)

* Adding support for outstanding builders (digitalocean,docker,google,openstack and qemu)
* Added more robust logging support

## 0.0.2 (Internal)

* Removed ability to name post-processors due to packer template change.

## 0.0.1 (Internal)

* Initial private release
* Supports Amazon, Virtualbox and VMWare builders