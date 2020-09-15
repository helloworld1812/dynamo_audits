require File.expand_path('../../spec_helper', __FILE__)
require 'support/active_record'

RSpec.describe DynamoAudits::Auditable do
  before(:each) do
    DynamoAudits.configuration.enabled = true
  end

  after(:each) do
    DynamoAudits.reset
  end

  describe '.dynamo_auditing_enabled?' do
    it 'should return true' do
      user =  User.new(first_name: 'Bill')
      expect(user.send(:dynamo_auditing_enabled?)).to be true
    end

    it 'should return false when this gem is disabled in this environment' do
      DynamoAudits.configuration.enabled = false
      user =  User.new(first_name: 'Bill')
      expect(user.send(:dynamo_auditing_enabled?)).to be false
    end

    it 'should return false when this table is ignored' do
      DynamoAudits.configuration.ignored_tables = ['users']
      user =  User.new(first_name: 'Bill')
      expect(user.send(:dynamo_auditing_enabled?)).to be false
    end
  end

  describe '.audit_create_to_dynamodb' do
    it 'should call write_audit_to_dynamodb' do
      user =  User.new(first_name: 'Bill')
      allow(user).to receive(:write_audit_to_dynamodb).and_return(true)
      expect(user).to receive(:write_audit_to_dynamodb).once
      user.save
    end
  end

  describe '.audit_update_to_dynamodb' do
    it 'should call write_audit_to_dynamodb' do
      user =  User.create(first_name: 'Bill')
      allow(user).to receive(:write_audit_to_dynamodb).and_return(true)
      expect(user).to receive(:write_audit_to_dynamodb).once
      user.update(first_name: 'Gates')
    end

    it 'should skip ignored attributes' do
      DynamoAudits.configuration.ignored_attributes = ['created_at', 'updated_at']
      user =  User.create(first_name: 'Bill')
      allow(user).to receive(:write_audit_to_dynamodb).and_return(true)
      expect(user).to receive(:write_audit_to_dynamodb).never
      user.update(created_at: Time.now)
    end
  end

  describe '.audit_destroy_to_dynamodb' do
    it 'should call write_audit_to_dynamodb' do
      user =  User.create(first_name: 'Bill')
      allow(user).to receive(:write_audit_to_dynamodb).and_return(true)
      expect(user).to receive(:write_audit_to_dynamodb).once
      user.destroy
    end
  end

  describe 'write_audit_to_dynamodb' do
    it 'should create a sidekiq job' do
      allow(DynamoAudits).to receive(:perform).and_return(true)
      user =  User.create(first_name: 'Bill')
    end
  end

  describe '___audited_changes___' do

  end
end
