Racker::Processor.register_template do |t|
  t.variables = {
    :iso_url => 'priority.img',
    :password => '~~',
  }
  t.description = 'some description'
  t.min_packer_version = '1.1.1'
end
