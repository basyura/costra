
class User < Sequel::Model
  set_schema do
    primary_key :id
    string      :name
  end
end
User.create_table unless User.table_exists?
