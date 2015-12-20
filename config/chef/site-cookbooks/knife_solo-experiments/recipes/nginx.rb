bash "Install PGP key and add HTTPS support for APT" do
  code <<-EOF
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
    sudo apt-get install -y apt-transport-https ca-certificates
  EOF
end

bash "add APT repo" do
  code <<-EOF
    sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
    # sudo apt-get update
  EOF
end


bash "Install passenger+nginx" do
  code <<-EOF
    sudo apt-get install -y --force-yes nginx-extras passenger
  EOF
end

nginx_conf_path = "/etc/nginx/nginx.conf"
execute "rm -f #{nginx_conf_path}" do
  only_if { File.exists?(nginx_conf_path) }
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  variables({
                passenger_ruby: "/home/#{node['user']['name']}/.rbenv/shims/ruby",
                rails_env:      node['env'],
                app_root:       "/var/www/#{node['app']}/current/public"
            })
end

['enabled', 'available'].each do |type_of_action|
  default_path = "/etc/nginx/sites-#{type_of_action}/default"
  execute "rm -f #{default_path}" do
    only_if { File.exists?(default_path) }
  end
end

template "/etc/nginx/sites-available/#{node['app']}" do
  source "#{node['app']}.erb"
  variables({
                rails_env:   node['env'],
                server_name: node['app'],
                app_root:    "/var/www/#{node['app']}/current/public"

            })
end

available_path = "/etc/nginx/sites-available/#{node['app']}"
execute "sudo ln -s #{available_path} /etc/nginx/sites-enabled/#{node['app']}" do
  only_if { File.exists?(available_path) }
end
