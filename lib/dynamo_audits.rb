require 'active_record'
require 'active_support'
require "dynamo_audits/version"
require 'dynamo_audits/auditable'
require 'dynamo_audits/audit_job'
require 'dynamo_audits/controller_context'

module DynamoAudits
  DEFAULT_IGNORED_ATTRIBUTES = %w(updated_at created_at)

  class Configuration
    attr_accessor :dynamodb_table, :env, :enabled, :logger, :ignored_attributes, :ignored_klasses, :region

    def initialize
     # Set default value if user forget to configure 
      self.ignored_attributes = DEFAULT_IGNORED_ATTRIBUTES
      self.ignored_klasses = []
      self.enabled = false
      self.env = defined?(Rails) && Rails.env.to_s
      self.logger = Logger.new(STDOUT)
      self.dynamodb_table = 'audit_logs_' + self.env
      self.region = 'us-west-2'
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
