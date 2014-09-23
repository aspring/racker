Racker::Processor.register_template do |t|

  # Define the variables
  t.variables = {
    'iso_checksum'              => '6232efa014d9c6798396b63152c4c9a08b279f5e',
    'iso_checksum_type'         => 'sha1',
    'iso_url'                   => 'http://mirrors.kernel.org/centos/6.4/isos/x86_64/CentOS-6.4-x86_64-minimal.iso',
    'kickstart_file'            => 'template1-ks.cfg',
    'vagrant_output_file'       => "./boxes/centos-6.4-{{.Provider}}.box"
  }

  # Define the builders
  t.builders['virtualbox-vagrant'] = {
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

  t.builders['vmware-vagrant'] = {
    'type'                      => 'vmware-iso',
    'guest_os_type'             => 'centos-64',
    'headless'                  => true,
    'tools_upload_flavor'       => 'linux',
    'iso_checksum'              => '{{user `iso_checksum`}}',
    'iso_checksum_type'         => '{{user `iso_checksum_type`}}',
    'iso_url'                   => '{{user `iso_url`}}',
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
    'vmdk_name'                 => 'centos',
    'vmx_data'                  => {
      'cpuid.coresPerSocket'          => '1',
      'memsize'                       => '1024',
      'numvcpus'                      => '1',
      'isolation.tools.copy.disable'  => 'false',
      'isolation.tools.paste.disable' => 'false'
    }
  }

  t.builders['amazon'] = {
    'type'                      => 'amazon-ebs',
    'region'                    => 'us-east-1',
    'source_ami'                => 'ami-testami',
    'instance_type'             => 't1.micro',
    'ssh_username'              => 'root',
    'ssh_timeout'               => '5m',
    'ami_name'                  => 'packer-centos-6 {{timestamp}}',
    'ami_block_device_mappings' => {
      '/dev/sda' => {
        'device_name'           => '/dev/sda',
        'volume_size'           => 8,
        'delete_on_termination' => true
      },
      '/dev/sdb' => {
        'device_name'           => '/dev/sdb',
        'volume_size'           => 8,
        'delete_on_termination' => true
      }
    },
    'ami_regions' => [
      'us-west-1',
      'us-west-2'
    ]
  }

  # Define the provisioners
  t.provisioners = {
    0 => {
      'yum-install-packages' => {
        'type' => 'shell',
        'script' => 'scripts/centos-6/yum-install-packages.sh'
      },
      'disable-sshd-dns-lookup' => {
        'type' => 'shell',
        'script' => 'scripts/common/disable-sshd-dns-lookup.sh'
      },
      'no-tty-sudo' => {
        'type' => 'shell',
        'script' => 'scripts/common/no-tty-sudo.sh'
      },
      'set-xen-device-name' => {
        'type' => 'shell',
        'script' => 'scripts/common/set-xen-device-names.sh'
      },
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
          'scripts/centos-6/install-guest-additions-dependencies.sh',
          'scripts/common/install-guest-additions.sh'
        ],
        'only' => ['virtualbox-vagrant', 'vmware-vagrant']
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
        'only' => ['virtualbox-vagrant']
      },
      'prepare-ec2-instance' => {
        'type' => 'shell',
        'script' => 'scripts/common/prepare-ec2-instance.sh',
        'only' => ['amazon']
      },
      'update-staic-ip-files' => {
        'type' => 'file',
        'source' => 'uploads/static-ip',
        'destination' => '/root',
        'only' => ['vmware-vagrant']
      },
    },
    999 => {
      'yum-remove-packages' => {
        'type'    => 'shell',
        'script'  => 'scripts/centos-6/yum-remove-packages.sh'
      },
      'clean-unnecessary-files' => {
        'type'    => 'shell',
        'script'  => 'scripts/centos-6/clean-unnecessary-files.sh'
      },
      'zero-empty-space' => {
        'type'    => 'shell',
        'script'  => 'scripts/common/zero-empty-space.sh'
      },
    }
  }

  # Define the post-processors
  t.postprocessors['vagrant'] = {
    'type' => 'vagrant',
    'output' => '{{user `vagrant_output_file`}}',
    'compression_level' => 7,
    'keep_input_artifact' => true,
    'only' => ['virtualbox-vagrant','vmware-vagrant']
  }

end
