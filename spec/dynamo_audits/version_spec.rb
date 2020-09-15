require File.expand_path('../../spec_helper', __FILE__)

RSpec.describe DynamoAudits::VERSION do
  it "has a version number" do
    expect(DynamoAudits::VERSION).not_to be nil
  end
end
