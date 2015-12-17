bash "Installing Passenger Open Source Edition" do
  code <<-EOF
  gem install passenger -v #{node['passenger-nginx']['passenger']['version']}
  EOF
  user "root"

  regex = Regexp.escape("passenger (#{node['passenger-nginx']['passenger']['version']})")
  not_if { `bash -c "source #{node['passenger-nginx']['rvm']['rvm_shell']} && gem list"`.lines.grep(/^#{regex}/).count > 0 }
end

bash "Installing passenger nginx module and nginx from source" do
  code <<-EOF
  source #{node['passenger-nginx']['rvm']['rvm_shell']}
  passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download --extra-configure-flags="\"--with-http_gzip_static_module #{node['passenger-nginx']['nginx']['extra_configure_flags']}\""
  EOF
  user node['user']['name']
  not_if { File.exists? "/opt/nginx/sbin/nginx" }
end


passenger_root = "/usr/local/rvm/gems/ruby-#{node['passenger-nginx']['ruby_version']}/gems/passenger-#{node['passenger-nginx']['passenger']['version']}"

template "/opt/nginx/conf/nginx.conf" do
  source "nginx.conf.erb"
  variables({
    :ruby_version => node['passenger-nginx']['ruby_version'],
    :rvm => node['rvm'],
    :passenger_root => passenger_root,
    :passenger => node['passenger-nginx']['passenger'],
    :nginx => node['passenger-nginx']['nginx']
  })
end


default_path = "/etc/nginx/sites-enabled/default"
execute "rm -f #{default_path}" do
  only_if { File.exists?(default_path) }
end

directory "/etc/nginx/sites-enabled" do
  mode 0755
  action :create
  not_if { File.directory? "/opt/nginx/sites-enabled" }
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end
