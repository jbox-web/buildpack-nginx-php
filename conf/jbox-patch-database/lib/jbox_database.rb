# encoding: utf-8

module JboxDatabase
  require 'getoptlong'
  require 'active_record'
  require 'mysql2'
  require 'yaml'

  require_relative 'adapter/base'
  require_relative 'adapter/mysql'

  require_relative 'jbox_database/base'
  require_relative 'jbox_database/dumper'
  require_relative 'jbox_database/migrator'
  require_relative 'jbox_database/prestashop_domain_updater'
  require_relative 'jbox_database/prestashop_password_updater'

  CLASS_MAPPING = {
    migrate:         'JboxDatabase::Migrator',
    dump:            'JboxDatabase::Dumper',
    update_domain:   'JboxDatabase::PrestashopDomainUpdater',
    update_password: 'JboxDatabase::PrestashopPasswordUpdater'
  }

  class JboxDatabaseError < StandardError; end
  class MissingParameterError < JboxDatabaseError; end
  class DatabaseConnectionError < JboxDatabaseError; end
  class MissingDirectoryError < JboxDatabaseError; end

  class << self

    def execute!(action, app_dir)
      klass_name = get_klass_name_for(action)
      klass = load_constant(klass_name)
      begin
        status ''
        status "#{klass_name}"
        status '=' * klass_name.length
        # status ''
        # status "Directory : #{app_dir}"
        klass.new(app_dir).run!
      rescue MissingParameterError => e
        error("Database parameter is missing : '#{e.message}', exiting !")
      rescue DatabaseConnectionError => e
        error("Database connection error : '#{e.message}', exiting !")
      rescue MissingDirectoryError => e
        error("Directory/File does not exist : '#{e.message}', exiting !")
      rescue => e
        error("Error : '#{e.message}', exiting !")
      else
        exit 0
      end
    end


    def load_constant(name)
      name.split('::').inject(Module) do |mod_path, mod_to_find|
        mod_path.const_get(mod_to_find)
      end
    end


    def get_klass_name_for(action)
      CLASS_MAPPING[action]
    end


    def status(message)
      logger "       #{message}"
    end


    def error(message)
      logger "       #{message}"
      logger ''
      exit 1
    end


    def logger(message)
      $stdout.sync = true
      $stdout.puts "\e[1G#{message}"
      $stdout.flush
    end

  end

end
