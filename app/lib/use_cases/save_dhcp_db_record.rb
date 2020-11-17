module UseCases
  class SaveDhcpDbRecord
    def initialize(generate_kea_config:, verify_kea_config:, publish_kea_config:, deploy_dhcp_service:)
      @generate_kea_config = generate_kea_config
      @verify_kea_config = verify_kea_config
      @publish_kea_config = publish_kea_config
      @deploy_dhcp_service = deploy_dhcp_service
    end

    def call(record)
      record.transaction do
        if record.save
          kea_config = generate_kea_config.call
          if verify_kea_config.call(kea_config)
            publish_kea_config.call(kea_config)
            deploy_dhcp_service.call
            return true
          else
            raise KeaConfigInvalidError
          end
        else
          return false
        end
      rescue KeaConfigInvalidError
        record.errors.add(:base, "These changes would result in an invalid DHCP configuration")
        return false
      end
    end

    private

    attr_reader :generate_kea_config,
      :verify_kea_config,
      :publish_kea_config,
      :deploy_dhcp_service

    class KeaConfigInvalidError < StandardError; end
  end
end
