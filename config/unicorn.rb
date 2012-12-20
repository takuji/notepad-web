rails_env = ENV['RAILS_ENV'] || 'production'
worker_processes (rails_env == 'production' ? 1 : 1)

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
#listen '/data/github/current/tmp/sockets/unicorn.sock', :backlog => 2048

stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])

before_fork do |server, worker|
  old_pid = "#{ server.config[:pid] }.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server,worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  # per-process listener ports for debugging/admin:
  #addr = "127.0.0.1:#{9293 + worker.nr}"

  # the negative :tries parameter indicates we will retry forever
  # waiting on the existing process to exit with a 5 second :delay
  # Existing options for Unicorn::Configurator#listen such as
  # :backlog, :rcvbuf, :sndbuf are available here as well.
  #server.listen(addr, :tries => -1, :delay => 5, :backlog => 128)
end
