
class Order < Sequel::Model
  one_to_many :costs
  set_schema do
    primary_key :id
    string      :name
    string      :code
    integer     :amount
    date        :from
    date        :to
  end
  def cost
    amount * Config["cost_percent"]
  end
  def use_percent
    sprintf("%.1f" , (amount - remain) / amount * 100)
  end
  def remain
    rem = amount * Config["cost_percent"]
    rem - costs.inject(0){|sum , v| sum += v.hour * Config["hour_price"] + v.travel ||= 0}
  end
end
Order.create_table unless Order.table_exists?
