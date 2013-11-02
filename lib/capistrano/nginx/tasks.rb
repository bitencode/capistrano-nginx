Capistrano::Configuration.instance.load do
  namespace :nginx do
    desc "Setup application in nginx"
    task "setup", :role => :web do
      config_file = "config/deploy/nginx_conf.erb"
      unless File.exists?(config_file)
        config_file = File.join(File.dirname(__FILE__), "../../generators/capistrano/nginx/templates/_nginx_conf.erb")
      end
      config = ERB.new(File.read(config_file)).result(binding)
      put config, "/tmp/#{application}"
      invoke_command "mv /tmp/#{application} /etc/nginx/sites-available/#{application}", :via => :sudo
      nginx.enable_site
    end

    [:stop, :start, :restart, :reload].each do |action|
      desc "#{action.to_s.capitalize} nginx"
      task action, :roles => :web do
        invoke_command "service nginx #{action.to_s}", :via => :sudo
      end
    end

    desc 'Enable nginx site'
    task :enable_site do
      invoke_command "ln -sf /etc/nginx/sites-available/#{application}.conf /etc/nginx/sites-enabled/#{application}.conf", :via => :sudo
      nginx.reload
    end

    desc 'Disable nginx site'
    task :disable_site do
      invoke_command "unlink /etc/nginx/sites-enabled/#{application}.conf", :via => :sudo
      nginx.reload
    end
  end
end
