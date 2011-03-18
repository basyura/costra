
class Cost < Sequel::Model
  many_to_one :order
  set_schema do
    primary_key :id
    foreign_key :order_id , :order
    integer     :user_id
    float       :hour
    float       :travel
    date        :date
  end
  def user_name
    User.find(:id => user_id).name
  end
end
Cost.create_table unless Cost.table_exists?
