# encoding: utf-8

module JboxDatabase
  class Base

    DB_SETTINGS = %w[ db_type db_host db_name db_user db_pass ]

    attr_reader :app_dir
    attr_reader :db_type
    attr_reader :db_host
    attr_reader :db_name
    attr_reader :db_user
    attr_reader :db_pass


    def initialize(app_dir)
      @app_dir = app_dir
      load_environment_variables
    end


    def run!
      raise NotImplementedError
    end


    private


      def db_connection
        @db_connection ||= Adapter::Base.call(database_settings)
      end


      def load_environment_variables
        DB_SETTINGS.each do |param|
          param_name = param.upcase
          if !ENV[param_name].nil? && !ENV[param_name].empty?
            instance_variable_set("@#{param}" , ENV[param_name])
          else
            raise JboxDatabase::MissingParameterError, param_name
          end
        end
      end


      def database_settings
        params = {}
        params[:db_type] = db_type
        params[:db_host] = db_host
        params[:db_name] = db_name
        params[:db_user] = db_user
        params[:db_pass] = db_pass
        params
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
        JboxDatabase.logger(message)
      end

  end
end
