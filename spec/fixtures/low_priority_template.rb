Racker::Processor.register_template do |t|
  t.variables = {
    :iso_url => 'os.img',
    :password => 'password',
    :nil => nil,
  }
end
