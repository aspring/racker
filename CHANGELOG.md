## 0.1.6 (2014-09-16)

* Fixed `uninitialized constant Racker::Builders::Null` bug.

## 0.1.5 (2014-09-08)

* Added support for VirtualBox `import_flags` options which were added in Packer 0.7.0.

## 0.1.4 (2014-08-07)

New Features:
* Added support for OpenStack `security_groups` options.
* Added `null` builder support.
* Added `parallels` builder support.  (UNTESTED)

## 0.1.3 (2014-05-06)

* Added support for VirtualBox `export_opts` and `vboxmanage_post` options which were added in Packer 0.6.0.

## 0.1.2 (2014-03-11)

* Fix quiet option cli setting

## 0.1.1 (2014-03-06)

New Features:
* Added command line option to surpress output.
* Added the ability to set the knockout prefix from the command line.

Bug Fixes:
* Do not create empty Packer namespace entries if the Racker template does not contain the namespace.
* Changed default knockout prefix from `--` to `~~` as it conflicted with certain Virtualbox builder keys.

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