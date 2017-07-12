# encoding: utf-8

module JboxDatabase
  class Migrator < Base

    attr_reader :jbox_sql_dir
    attr_reader :jbox_sql_init_dir
    attr_reader :jbox_sql_patch_dir
    attr_reader :jbox_sql_init_01
    attr_reader :jbox_sql_init_02

    attr_reader :patch_suffix


    def initialize(app_dir)
      super

      # Define JBox SQL directories
      @jbox_sql_dir       = File.join(app_dir, 'jbox-sql')
      @jbox_sql_init_dir  = File.join(jbox_sql_dir, 'init')
      @jbox_sql_patch_dir = File.join(jbox_sql_dir, 'patches')

      # Define JBox base patches
      @jbox_sql_init_01   = File.join(jbox_sql_init_dir, '01_init_base.sql')
      @jbox_sql_init_02   = File.join(jbox_sql_init_dir, '02_init_jbox.sql')

      @patch_suffix  = '_patch'
    end


    def run!
      ready_for_migrations?

      begin
        get_migrations_list
      rescue ActiveRecord::StatementInvalid => e
        init_database
      else
        apply_patches
      end
    end


    private


      def ready_for_migrations?
        [
          jbox_sql_dir,
          jbox_sql_init_dir,
          jbox_sql_patch_dir,
          jbox_sql_init_01,
          jbox_sql_init_02
        ].each do |file|
          if !File.exists?(file)
            raise JboxDatabase::MissingDirectoryError, file
          end
        end
      end


      def get_migrations_list
        results = db_connection.query("SELECT * FROM schema_migrations")
        list = []
        results.each(:as => :array) do |row|
          list.concat(row)
        end
        list
      end


      def init_database
        status ""
        status "Database does not seem to be initialized, initializing it..."
        status ""

        # Joomla base dump
        load_sql_dump(jbox_sql_init_01)

        # JBox table version
        load_sql_dump(jbox_sql_init_02)

        status ''
        apply_patches
      end


      def load_sql_dump(file, opts = {})
        status "  * Loading sql file : '#{File.basename(file)}'"

        save_migration = opts.delete(:save_migration){ false }
        migration_name = opts.delete(:migration_name){ nil }

        db_connection.load_dump(file)

        if save_migration
          db_connection.query("INSERT INTO schema_migrations (version) VALUES('#{migration_name}')")
        end
      end


      def apply_patches
        status ""
        status "Apply patches..."
        status ""

        # Get list of patches
        if get_patches_list.empty?
          status '  * No patch to apply found, exiting...'
          status ''
          exit 0
        else
          get_patches_list.each do |patch|
            patch_name = "#{File.basename(patch)}#{patch_suffix}"
            if get_migrations_list.include?(patch_name)
              status "  * Already migrated : '#{File.basename(patch)}', skipping..."
              status ''
              next
            else
              load_sql_dump(patch, save_migration: true, migration_name: patch_name)
            end
          end
        end
      end


      def get_patches_list
        dir = File.join(jbox_sql_patch_dir, "[0-9][0-9][0-9]_*\.sql")
        Dir.glob(dir).sort
      end

  end
end
