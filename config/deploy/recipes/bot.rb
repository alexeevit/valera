namespace :bot do
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, fetch(:bot_systemctl_service_name)
    end
  end

  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, fetch(:bot_systemctl_service_name)
    end
  end

  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, fetch(:bot_systemctl_service_name)
    end
  end
end
