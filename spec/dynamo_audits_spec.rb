require 'spec_helper'

RSpec.describe DynamoAudits do
  describe '.configure' do
    it 'should successfully configure the gem' do
      DynamoAudits.configure do |config|
        config.ignored_tables = ['some_table']
        config.ignored_attributes = ['created_at', 'updated_at']
      end

      expect(DynamoAudits.configuration.ignored_tables).to eq(['some_table'])
      expect(DynamoAudits.configuration.ignored_attributes).to eq(['created_at', 'updated_at'])
    end
  end

  describe '.reset' do
    it 'should reset to default value' do
      DynamoAudits.configuration.enabled = true
      DynamoAudits.reset
      expect(DynamoAudits.configuration.enabled).to be false
    end
  end

  describe '.configuration' do
    it 'should return an Configuration object' do
      expect(DynamoAudits.configuration.is_a?(DynamoAudits::Configuration)).to be true
    end
  end

  describe '.store' do
    it 'should return a hash' do
      expect(DynamoAudits.store.is_a?(Hash)).to be true
    end
  end

  describe '.purge_store!' do
    it 'should purge the store' do
      DynamoAudits.store[:current_user] = OpenStruct.new(id: 1, email: 'ryan@workstream.is')
      DynamoAudits.purge_store!
      expect(DynamoAudits.store[:current_user].nil?).to be true
    end
  end
end
