require 'customer'
require 'customer_datasource'

describe Customer do
  let(:datasource) { CustomerDatasource.new }
  let(:customer) { Customer.new :one, datasource }

  describe "#initialize" do
    it "stores an id and a datasource" do
      customer.id.should == :one
      customer.datasource.should == datasource
    end
  end

  describe "#first" do
    it "gets the first name of a customer" do
      customer.first.should == "First: 'Yukihiro'"
    end
  end

  describe "#last" do
    it "gets the last name of a customer" do
      customer.last.should == "Last: 'Matsumoto'"
    end
  end

  describe "#email" do
    it "gets the email address of a customer" do
      customer.email.should == "Email: 'matz@bostonrb.org'"
    end
  end

  describe "#age" do
    it "gets the age of a customer" do
      customer.age.should == "Age: 48"
    end
  end
end
