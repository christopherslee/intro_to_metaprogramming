# this class intentionally does not use metaprogramming for simplicty
# and clarity while trying to teach a workshop on metaprogramming. extra
# credit for refactoring it with metaprogramming techniques learned in
# the workshop!
class CustomerDatasource
  def initialize
    @nosql_database = {
      :one => {
        :first => {
          :value => "Yukihiro",
          :datatype => :string
        },
        :last => {
          :value => "Matsumoto",
          :datatype => :string
        },
        :email => {
          :value => "matz@bostonrb.org",
          :datatype => :string
        },
        :age => {
          :value => 48,
          :datatype => :integer
        }
      }
    }
  end

  def get_first_value(id)
    fetch_record(id)[:first][:value]
  end

  def get_first_datatype(id)
    fetch_record(id)[:first][:datatype]
  end

  def get_last_value(id)
    fetch_record(id)[:last][:value]
  end

  def get_last_datatype(id)
    fetch_record(id)[:last][:datatype]
  end

  def get_email_value(id)
    fetch_record(id)[:email][:value]
  end

  def get_email_datatype(id)
    fetch_record(id)[:email][:datatype]
  end

  def get_age_value(id)
    fetch_record(id)[:age][:value]
  end

  def get_age_datatype(id)
    fetch_record(id)[:age][:datatype]
  end

  private

  def fetch_record(id)
    @nosql_database.fetch(id.to_sym) do
      raise "No customer found matching id: #{id}"
    end
  end
end
