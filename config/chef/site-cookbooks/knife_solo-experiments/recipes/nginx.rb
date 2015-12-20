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

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  variables({
                passenger_ruby: "/home/#{node['user']['name']}/.rbenv/shims/ruby",
                rails_env: node['env'],
                app_root: "/var/www/#{node['app']}/current/public"
            })
end
