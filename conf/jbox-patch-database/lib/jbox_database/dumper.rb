# encoding: utf-8

module JboxDatabase
  class Dumper < Base

    attr_reader :dump_path


    def initialize(app_dir)
      super
      @dump_path = File.join(app_dir, 'jbox-sql-dump').to_s
      FileUtils.mkdir_p(dump_path)
    end


    def run!
      status ''
      status "Dumping database '#{db_name}' to #{dump_path}"
      status ''
      db_connection.dump_database(dump_path)
    end

  end
end
