require 'customer_datasource'

describe CustomerDatasource, :skip => true do
  it "returns the first name of a customer" do
    subject.get_first_value(:one).should == "Yukihiro"
  end

  it "returns the datatype for the first name" do
    subject.get_first_datatype(:one).should == :string
  end

  it "returns the last name of a customer" do
    subject.get_last_value(:one).should == "Matsumoto"
  end

  it "returns the datatype for the last name" do
    subject.get_last_datatype(:one).should == :string
  end

  it "returns the email address of a customer" do
    subject.get_email_value(:one).should == "matz@bostonrb.org"
  end

  it "returns the datatype for the email" do
    subject.get_email_datatype(:one).should == :string
  end

  it "returns the age of a customer" do
    subject.get_age_value(:one).should == 48
  end

  it "returns the datatype for the age" do
    subject.get_age_datatype(:one).should == :integer
  end

  it "raises an error if there is no customer record" do
    expect{ subject.get_first_value(:none) }.to raise_error("No customer found matching id: none")
  end
end
