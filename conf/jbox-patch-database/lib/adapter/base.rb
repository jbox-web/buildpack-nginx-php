# encoding: utf-8

module Adapter
  class Base


    def initialize(database_settings)
      @database_settings = database_settings
    end


    class << self

      def sanitize_dump(dump)
        buffer = ''
        File.open(dump, 'r:utf-8') do |f|
          f.each_line do |line|
            next if line.start_with?('--')
            next if line.start_with?('/*')
            next if line.strip.empty?
            buffer << line
          end
        end
        buffer.split(";\n")
      end


      def call(database_settings = {})
        db_type = database_settings[:db_type] || 'mysql'
        klass = JboxDatabase.load_constant(get_adapter_klass(db_type))
        klass.new(database_settings).get_instance
      end


      def get_adapter_klass(db_type)
        db_type == 'mysql' ? 'Adapter::Mysql' : 'Adapter::Postgresql'
      end

    end


    def dump_database(path)
      raise NotImplementedError
    end


    def load_dump(dump)
      self.class.sanitize_dump(dump).each do |query|
        ActiveRecord::Base.transaction do
          query(query)
        end
      end
    end


    def query(query)
      begin
        $db_connection.connection.execute(query)
      rescue Mysql2::Error => e
        raise JboxDatabase::DatabaseConnectionError, e.message
      end
    end


    def get_instance
      $db_connection = ActiveRecord::Base.establish_connection(database_settings)
      return self
    end


    def database_settings
      options = {}
      options[:adapter]  = get_adapter_name
      options[:database] = @database_settings[:db_name]
      options[:username] = @database_settings[:db_user]
      options[:password] = @database_settings[:db_pass]
      options = options.merge(get_host_type => get_db_host)
      options
    end


    def get_adapter_name
      @database_settings[:db_type] == 'mysql' ? 'mysql2' : 'postgresql'
    end


    def get_db_host
      if @database_settings[:db_host].start_with?('localhost:')
        @database_settings[:db_host].split(':')[1]
      else
        @database_settings[:db_host]
      end
    end


    def get_host_type
      if @database_settings[:db_host].start_with?('localhost:')
        :socket
      else
        :host
      end
    end

  end
end
