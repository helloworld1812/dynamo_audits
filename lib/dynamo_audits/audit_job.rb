module DynamoAudits
  class AuditJob < ::ActiveJob::Base
    queue_as :default

    def perform(payload)
      DynamoAudits.configuration.client.put_item(payload)
    end
  end
end
