# encoding: utf-8

module Adapter
  class Mysql < Base

    def dump_database(path)
      command = [
        '/usr/bin/mysqldump',
        "--#{get_host_type}=#{get_db_host}",
        "--user=#{@database_settings[:db_user]}",
        "--password=#{@database_settings[:db_pass]}",
        @database_settings[:db_name],
        '|', 'gzip', '-c', '|', 'cat', '>', "#{path}/#{@database_settings[:db_name]}.sql.gz"
      ].join(' ')

      system(command)
    end

  end
end
