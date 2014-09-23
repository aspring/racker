Racker::Processor.register_template do |t|
  # We use an alternative kickstart configuration for this template
  t.variables = {
    'kickstart_file'            => 'template2-ks.cfg',
  }

  # Knock out the amazon builder as it is not needed by this template
  t.builders['amazon'] = '~~'

  # Define the provisioners
  t.provisioners = {
    600 => {
      'chef-devops-base' => {
        'type'                            => 'chef-solo',
        'chef_environment'                => 'vagrant',
        'cookbook_paths'                  => ['{{user `chef_base_dir`}}/cookbooks'],
        'data_bags_path'                  => '{{user `chef_base_dir`}}/data_bags',
        'environments_path'               => '{{user `chef_base_dir`}}/environments',
        'roles_path'                      => '{{user `chef_base_dir`}}/roles',
        'run_list'                        => ['role[base]'],
        'skip_install'                    => true,
        'json'                            => {
        }
      },
      'cleanup-after-chef-solo' => {
        'type'    => 'shell',
        'inline'  => ['rm -rf /tmp/packer-chef-solo', 'rm -rf /tmp/encrypted_data_bag_secret']
      },
    },
    900 => {
      # Knockout the ec2 instance prep
      'prepare-ec2-instance' => '~~'
    }
  }
end
