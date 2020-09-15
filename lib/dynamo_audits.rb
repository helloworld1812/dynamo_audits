require 'active_record'
require 'active_support'
require 'active_job'
require "dynamo_audits/version"
require 'dynamo_audits/auditable'
require 'dynamo_audits/audit_job'
require 'dynamo_audits/controller_context'

module DynamoAudits
  DEFAULT_IGNORED_ATTRIBUTES = %w(updated_at created_at)

  class Configuration
    attr_accessor :dynamodb_table, :env, :enabled, :logger, :ignored_attributes, :ignored_tables, :region

    def initialize
      # Set default value if user forget to configure
      self.ignored_attributes = DEFAULT_IGNORED_ATTRIBUTES
      self.ignored_tables = []
      self.enabled = false
      self.region = 'us-west-2'

      if defined?(Rails)
        self.env = Rails.env.to_s
        self.logger = Rails.logger
        self.dynamodb_table = 'audit_logs_' + Rails.env.to_s
      else
        self.env = 'development'
        self.logger = Logger.new(STDOUT)
        self.dynamodb_table = 'audit_logs_development'
      end
    end

    def client
      Aws::DynamoDB::Client.new(region: self.region)
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      yield(configuration)
    end

    def reset
      @configuration = Configuration.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def store
      Thread.current[:dynamo_audits_store] ||= {}
    end

    def purge_store!
      Thread.current[:dynamo_audits_store] = {}
    end
  end
end

::ActiveRecord::Base.send(:include, DynamoAudits::Auditable)
