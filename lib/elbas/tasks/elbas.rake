require 'elbas'

namespace :elbas do
  desc "Create a new AWS AMI and Launch Configuration for a Scaling Group"
  task :scale do
    set :aws_access_key_id,     fetch(:aws_access_key_id,     ENV['AWS_ACCESS_KEY_ID'])
    set :aws_secret_access_key, fetch(:aws_secret_access_key, ENV['AWS_SECRET_ACCESS_KEY'])

    Elbas::AMI.create do |ami|
      p "ELBAS: Created AMI: #{ami.aws_counterpart.id}"
      Elbas::LaunchConfiguration.create(ami) do |lc|
        p "ELBAS: Created Launch Configuration: #{lc.aws_counterpart.name}"
        lc.attach_to_autoscale_group!
      end
    end

  end

  desc "List the Scaling Group's instances"
  task :list do
    running_instances = autoscale_group.ec2_instances.filter('instance-state-name', 'running')
    puts " "
    running_instances.each_with_index do |instance, num|
      puts "Instance ##{num+1}"
      puts "ID: #{instance.id}"
      puts "Public DNS Name: #{instance.dns_name}"
      puts "Private DNS Name: #{instance.private_dns_name}"
      puts "Public IP: #{instance.ip_address}"
      puts "Private IP: #{instance.private_ip_address}"
      puts " "
    end
  end
end
