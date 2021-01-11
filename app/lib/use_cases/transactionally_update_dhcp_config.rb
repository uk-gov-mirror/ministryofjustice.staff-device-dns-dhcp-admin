module UseCases
  class TransactionallyUpdateDhcpConfig
    def initialize(generate_kea_config:, verify_kea_config:, publish_kea_config:)
      @generate_kea_config = generate_kea_config
      @verify_kea_config = verify_kea_config
      @publish_kea_config = publish_kea_config
    end

    def call(record, operation)
      ApplicationRecord.transaction do
        if operation.call
          kea_config = generate_kea_config.call
          config_verification_result = verify_kea_config.call(kea_config)
          if config_verification_result.success?
            publish_kea_config.call(kea_config)
            return true
          else
            raise KeaConfigInvalidError.new(config_verification_result.error.message)
          end
        else
          return false
        end
      end
    rescue KeaConfigInvalidError => error
      record.errors.add(:base, error.message)
      false
    end

    private

    attr_reader :generate_kea_config,
      :verify_kea_config,
      :publish_kea_config

    class KeaConfigInvalidError < StandardError; end
  end
end
