require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: "test/test.db"
)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :first_name
    t.string :last_name
    t.string :email
    t.timestamps
  end
end

class User < ActiveRecord::Base

end
