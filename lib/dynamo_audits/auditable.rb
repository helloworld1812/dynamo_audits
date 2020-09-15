module DynamoAudits
  module Auditable
    extend ActiveSupport::Concern

    included do
      after_create   :audit_create_to_dynamodb,  if: :dynamo_auditing_enabled?
      before_update  :audit_update_to_dynamodb,  if: :dynamo_auditing_enabled?
      before_destroy :audit_destroy_to_dynamodb, if: :dynamo_auditing_enabled?
    end

    private

    def dynamo_auditing_enabled?
      return false if DynamoAudits.configuration.ignored_klasses.include?(self.class)
      return false if !DynamoAudits.configuration.enabled
      return true
    end

    def audit_create_to_dynamodb
      write_audit_to_dynamodb(action: 'create', audited_changes: attributes)
    end

    def audit_update_to_dynamodb
      if ___audited_changes___.present?
        write_audit_to_dynamodb(action: 'update', audited_changes: ___audited_changes___)
      end
    end

    def audit_destroy_to_dynamodb
      write_audit_to_dynamodb(action: 'destroy', audited_changes: attributes) unless new_record?
    end

    def write_audit_to_dynamodb(options)
      user, company = nil, nil

      if DynamoAudits.store[:current_controller].present?
        user = DynamoAudits.store[:current_user]
        company = DynamoAudits.store[:current_company]
      else
        # Sidekiq middleware: TODO
        user = nil
        company = nil
      end

      item = {
        uuid: SecureRandom.uuid,
        timestamp: Time.now.utc.to_s,
        action: options[:action],
        table_name: self.class.table_name,
        table_id: self.id,
        table_name_and_id: "#{self.class.table_name}-#{self.id}",
        audited_changes: options[:audited_changes].to_json,
        request_uuid: DynamoAudits.store[:request_uuid],
        env: DynamoAudits.configuration.env
      }

      item.merge!(company_id: company.id) if company.present?
      item.merge!(company_id: user.id) if user.present?

      params = {
        table_name: DynamoAudits.configuration.dynamodb_table,
        item: item
      }

      DynamoAudits::AuditJob.perform(params)
    rescue => e
      DynamoAudits.configuration.logger.error e.inspect
      DynamoAudits.configuration.logger.error options
    end

    def ___audited_changes___
      changes_to_save.except(*DynamoAudits.configuration.ignored_attributes)
    end
  end
end
