require 'optparse'
require 'fileutils'
require 'logger'

# Handles daemonizing of Ruby code
module Dash
  class Runner

    attr_accessor :options
    private :options, :options=

    def self.shutdown
      @@instance.shutdown
    end

    def initialize
      @app_name = File.basename($0)
      @@instance = self
    end
    
    def parse(&block)
      self.options = { 
                       :log_level => Logger::INFO,
                       :daemonize => false,
                       :pid_file => File.join('/var', 'run', "#{@app_name}.pid"),
                       :log_file => File.join('/var', 'log', "#{@app_name}.log"),
                     }

      OptionParser.new do |opts|
        opts.summary_width = 25

        opts.banner = "usage: #{@app_name} [options...]\n",
                      "       #{@app_name} --help\n"

        opts.separator ""; opts.separator "Process:"

        opts.on("-d", "Run as a daemon.") do
          options[:daemonize] = true
        end

        opts.on("--pid FILENAME", "save PID in FILENAME when using -d option.", "(default: #{options[:pid_file]})") do |pid_file|
          options[:pid_file] = File.expand_path(pid_file)
        end

        opts.on("--user USER", "User to run as") do |user|
          options[:user] = user.to_i == 0 ? Etc.getpwnam(user).uid : user.to_i
        end

        opts.on("--group GROUP", "Group to run as") do |group|
          options[:group] = group.to_i == 0 ? Etc.getgrnam(group).gid : group.to_i
        end

        opts.separator ""; opts.separator "Logging:"

        opts.on("-L", "--log [FILE]", "Path to print debugging information.") do |log_path|
          options[:logger] = File.expand_path(log_path)
        end

        opts.on("-l", "--syslog CHANNEL", "Write logs to the syslog instead of a log file.") do |channel|
          begin
            require 'syslog_logger'
          rescue LoadError => e
            require 'rubygems'
            require 'syslog_logger'
          end
          options[:syslog_channel] = channel
        end

        opts.on("-v", "Increase logging verbosity (may be used multiple times).") do
          options[:log_level] -= 1
        end

        opts.separator ""; opts.separator "Miscellaneous:"

        opts.on_tail("-?", "--help", "Display this usage information.") do
          puts "#{opts}\n"
          exit
        end
        
        # application-specific parameters
        yield opts if block_given?

      end.parse!
    end

    def start
      raise ArgumentError, "Please pass an application block to execute" unless block_given?
      
      @process = ProcessHelper.new(options)
      pid = @process.running?
      if pid
        STDERR.puts "There is already a #{@app_name} process running (pid #{pid}), exiting."
        exit(1)
      elsif pid.nil?
        STDERR.puts "Cleaning up stale pidfile at #{options[:pid_file]}."
      end

      drop_privileges

      @process.daemonize if options[:daemonize]

      setup_signal_traps
      @process.write_pid_file if options[:daemonize]

      # This block will return when the process is exiting.
      yield options

      @process.remove_pid_file
    end

    def drop_privileges
      Process.egid = options[:group] if options[:group]
      Process.euid = options[:user] if options[:user]
    end

    def shutdown
      STDOUT.puts "Shutting down."
      exit(0)
    end

    def setup_signal_traps
      Signal.trap("INT") { shutdown }
      Signal.trap("TERM") { shutdown }
    end
  end

  class ProcessHelper

    def initialize(options)
      @log_file = options[:logger]
      @pid_file = options[:pid_file]
      @user = options[:user]
      @group = options[:group]
    end

    def safefork
      begin
        if pid = fork
          return pid
        end
      rescue Errno::EWOULDBLOCK
        sleep 5
        retry
      end
    end

    def daemonize
      sess_id = detach_from_terminal
      exit if pid = safefork

      Dir.chdir("/")
      File.umask 0000

      close_io_handles
      redirect_io

      return sess_id
    end

    def detach_from_terminal
      srand
      safefork and exit

      unless sess_id = Process.setsid
        raise "Couldn't detach from controlling terminal."
      end

      trap 'SIGHUP', 'IGNORE'

      sess_id
    end

    def close_io_handles
      ObjectSpace.each_object(IO) do |io|
        unless [STDIN, STDOUT, STDERR].include?(io)
          begin
            io.close unless io.closed?
          rescue Exception
          end
        end
      end
    end

    def redirect_io
      begin; STDIN.reopen('/dev/null'); rescue Exception; end

      if @log_file
        begin
          STDOUT.reopen(@log_file, "a")
          STDOUT.sync = true
        rescue Exception
          begin; STDOUT.reopen('/dev/null'); rescue Exception; end
        end
      else
        begin; STDOUT.reopen('/dev/null'); rescue Exception; end
      end

      begin; STDERR.reopen(STDOUT); rescue Exception; end
      STDERR.sync = true
    end

    # def rescue_exception
    #   begin
    #     yield
    #   rescue Exception
    #   end
    # end

    def write_pid_file
      return unless @pid_file
      FileUtils.mkdir_p(File.dirname(@pid_file))
      File.open(@pid_file, "w") { |f| f.write(Process.pid) }
      File.chmod(0644, @pid_file)
    end

    def remove_pid_file
      return unless @pid_file
      File.unlink(@pid_file) if File.exists?(@pid_file)
    end

    def running?
      return false unless @pid_file

      pid = File.read(@pid_file).chomp.to_i rescue nil
      pid = nil if pid == 0
      return false unless pid

      begin
        Process.kill(0, pid)
        return pid
      rescue Errno::ESRCH
        return nil
      rescue Errno::EPERM
        return pid
      end
    end
  end
end
