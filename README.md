# Racker

* Website: http://github.com/aspring/racker

Racker is an opinionated Ruby DSL for generating Packer(www.packer.io) templates.

Racker is able to take multiple Racker templates, merge them together, and generate a single Packer template.  This process allows for deep merging Packer configuration pieces to give the user a more granular approach for creating and organizing templates, not currently possible with the Packer template format.

## Features

* Allows for building Packer templates from DRY modular templates
* Allows for commenting sections of the template
* Supports use of knockouts when merging

## Installation

    $ gem install racker
    
## Usage
To generate a Packer template from a Racker template, run:
    
    $ racker rackertemplate1.rb packertemplate.json
  
To generate a Packer template from multiple Racker templates, run:
    
    $ racker rackertemplate1.rb rackertemplate2.rb packertemplate.json
  
To merge multiple templates you can keep adding Racker templates:

    $ racker rackertemplate1.rb rackertemplate2.rb rackertemplate3.rb packertemplate.json

The output of the previous command will be template 1 deep merged with template2, the result of this merge is deep merged with template 3 then output as a packer template.

## Racker Template Syntax
The goal of Racker is to provide a template structure that allows for allowing full control of the template merging process to achieve the desired Packer template. 

In order to do this Racker takes an opinionated stance on the following:

* All arrays within Packer Builder namespace are converted to hashes with well defined keys -- this allows for easy knockout capability based on key name.
* The provisioners hash uses a Fixnum key to allow for defining an order that provisioners will be written to the Packer template.

#### Base Template Syntax

The most basic Racker template would be the following:

```ruby
Racker::Processor.register_template do |t|
end
```

This template would not define a variable, builder, provisioner or post-processor and would be a pretty boring template.

#### Variables Namespace

Racker templates support the `variables` namespace which is a hash.  This hash maps one to one to a Packer template's variables section.

This is an example of a basic `variables` definition:

```ruby
Racker::Processor.register_template do |t|
    # Define the variables
    t.variables = {
        'iso_checksum'              => '6232efa014d9c6798396b63152c4c9a08b279f5e',
        'iso_checksum_type'         => 'sha1',
        'iso_url'                   => 'http://mirrors.kernel.org/centos/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso',
        'kickstart_file'            => 'template1-ks.cfg',
        'vagrant_output_file'       => "./boxes/centos-6.4-{{.Provider}}.box"
    }
end
```

#### Builders Namespace

Racker templates support the `builders` namespace which is a hash, keyed by the name of the builder.  

All Packer arrays inside of this namespace should be represented as hashes in Racker.  Racker will use the value when creating the template, the key is there purely for allowing you to override/knockout as necessary.

This is an abbreviated example of adding a builder named 'test' that is a 'virtualbox-iso' builder type:

```ruby
Racker::Processor.register_template do |t|
    # Define the builders
    t.builders['test'] = {
        'type'                      => 'virtualbox-iso',
        'guest_os_type'             => 'RedHat_64',
        'headless'                  => true,
        'format'                    => 'ova',
        'guest_additions_path'      => "VBoxGuestAdditions_{{.Version}}.iso",
        'iso_checksum'              => "{{user `iso_checksum`}}",
        'iso_checksum_type'         => "{{user `iso_checksum_type`}}",
        'iso_url'                   => "{{user `iso_url`}}",
        'virtualbox_version_file'   => '.vbox_version',
        'boot_command'              => {
            0 => '<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/{{user `kickstart_file`}}<enter><wait>'
        },
        'boot_wait'                 => '10s',
        'http_directory'            => 'http_directory',
        'ssh_port'                  => 22,
        'ssh_username'              => 'root',
        'ssh_password'              => 'asdfasdf',
        'ssh_wait_timeout'          => '10000s',
        'shutdown_command'          => 'shutdown -P now',
        'disk_size'                 => 8096,
        'vboxmanage'                => {
            'memory'  => [ 'modifyvm', '{{.Name}}', '--memory',    '1024' ],
            'cpus'    => [ 'modifyvm', '{{.Name}}', '--cpus',      '1' ],
            'ioapic'  => [ 'modifyvm', '{{.Name}}', '--ioapic',    'on' ]
        }
    }
end
```
One of the sections of node in this builder is the `vboxmanage`.  It has been converted into a Hash to make it easier to knockout.

#### Provisioners Namespace

Racker templates support the `provisioners` namespace which is a Fixnum keyed hash.  

When generating the Packer template, Racker will order the provisioners based upon the Fixnum key, this allows complete control on the ordering of provisioners throughout Racker templates.

```ruby
Racker::Processor.register_template do |t|
    # Define the provisioners
    t.provisioners = {
        0 => {
            'update-cacert-bundle' => {
                'type' => 'shell',
                'script' => 'scripts/common/update-cacert-bundle.sh'
            },
        },
        300 => {
            'install-chef-11.8.0' => {
                'type' => 'shell',
                'script' => 'scripts/common/install-chef-11.8.0.sh'
            },
        },
        500 => {
            'install-guest-additions-dependencies' => {
                'type' => 'shell',
                'scripts' => [
                    'scripts/common/install-guest-additions.sh'
                ],
            },
        },
        750 => {
            'disable-services' => {
                'type' => 'shell',
                'script' => 'scripts/centos-6/disable-services.sh'
            },
        },
        900 => {
            'prepare-vagrant-instance' => {
                'type' => 'shell',
                'script' => 'scripts/common/prepare-vagrant-instance.sh',
                'only' => ['test']
            },
            'prepare-ec2-instance' => {
                'type' => 'shell',
                'script' => 'scripts/common/prepare-ec2-instance.sh',
                'only' => ['amazon']
            },
        }
    }
end
```

#### Post-Processors Namespace

Racker templates support the `postprocessors` namespace which is a hash, keyed by the name of the post-processor.

```ruby
Racker::Processor.register_template do |t|
    # Define the post-processors
    t.postprocessors['vagrant'] = {
        'type' => 'vagrant',
        'output' => '{{user `vagrant_output_file`}}',
        'compression_level' => 7,
        'keep_input_artifact' => true,
        'only' => ['virtualbox-vagrant','vmware-vagrant']
    }
end
```

### Putting it all together

Racker offers 2 very basic example templates `example/template1.rb` and `example/template2.rb` as well as the resulting packer template from the two templates run through Racker.

To experiement with these templates, after installing Racker, and cloning this repo you can execute the following:

    $ racker ./example/template1rb ./example/tempalte2.rb ./example/packer.json
    
While these two templates are not all inclusive of the capabilities of Racker, it shows off the ability to have a basic template, and a second template that removes the pieces of the template that target Amazon, as well as adds two chef solo provisioner steps.

## Testing

TODO: This section needs to be written

## Outstanding Development

* The following builders have not been fully tested:
    * docker
    * qemu
* Implement unit testing
* Travis CI
* Additional documentation work 
* Add capability to target specific packer versions should the packer template format change.
* Add quick init to generate a basic Racker template

## Contributions

Feel free to fork and request a pull, or submit a ticket
https://github.com/aspring/racker/issues

## License

This project is available under the MIT license. See LICENSE for details.