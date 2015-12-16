service 'ssh' do
  provider Chef::Provider::Service::Upstart
  supports [:status, :restart]
end
