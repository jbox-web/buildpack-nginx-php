# encoding: utf-8

module JboxDatabase
  class PrestashopDomainUpdater < Base

    PRESTA_SETTINGS = %w[ site_dns ]

    attr_reader :site_dns


    def initialize(app_dir)
      super

      # Load needed environment variables (it raises error if fails)
      load_prestashop_variables
    end


    def run!
      db_connection.query("UPDATE ps_configuration SET value = '#{site_dns}' WHERE name = 'PS_SHOP_DOMAIN'")
      db_connection.query("UPDATE ps_configuration SET value = '#{site_dns}' WHERE name = 'PS_SHOP_DOMAIN_SSL'")
      db_connection.query("UPDATE ps_shop_url SET domain = '#{site_dns}', domain_ssl = '#{site_dns}' WHERE id_shop = 1")

      status "Prestashop domain name has been updated, here the domain name : #{site_dns}"
    end


    private


      def load_prestashop_variables
        PRESTA_SETTINGS.each do |param|
          param_name = param.upcase
          if !ENV[param_name].nil?
            instance_variable_set("@#{param}" , ENV[param_name])
          else
            raise MissingParameterError, param_name
          end
        end
      end

  end
end
