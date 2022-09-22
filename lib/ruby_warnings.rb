ruby_version = (RbConfig::CONFIG['MAJOR'].to_i * 10) + RbConfig::CONFIG['MINOR'].to_i
if ruby_version >= 27
  Warning[:deprecated] = false
  ENV['RUBYOPT'] = '-W:no-deprecated'
else
  ENV['RUBYOPT']="-W0"
end
