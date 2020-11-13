require "rails_helper"

RSpec.describe ClientClass, type: :model do
  subject { build :client_class }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { should allow_value("example.com").for(:domain_name) }
  it { should allow_value("foo.example.com").for(:domain_name) }
  it { should allow_value("foo-bar-1.abc.123.example.com").for(:domain_name) }
  it { should allow_value("foo-BAR-1.ABC.123.example.com").for(:domain_name) }
  it { should_not allow_value("i_contain_an_at_sign@gov.uk").for(:domain_name) }
  it { should_not allow_value("测试.com").for(:domain_name) }
  it { should_not allow_value("me.example/.co").for(:domain_name) }

  it { should allow_value("AbC123-").for(:client_id) }
  it { should_not allow_value("abC.123-").for(:client_id) }
  it { should_not allow_value("测试.com").for(:client_id) }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :client_id }

  it do
    is_expected.not_to allow_value("abC.123-")
      .for(:client_id)
      .with_message("may only contain letters, numbers, underscores and dashes")
  end

  it do
    is_expected.to validate_presence_of(:domain_name_servers)
      .with_message("must contain at least one IPv4 address separated using commas")
  end

  it { is_expected.to validate_presence_of :domain_name }

  it "rejects invalid domain_name_servers" do
    option = build :option, domain_name_servers: "abcd,efg"
    expect(option).not_to be_valid
    expect(option.errors[:domain_name_servers]).to eq(["contains an invalid IPv4 address or is not separated using commas"])
  end

  describe "#domain_name_servers" do
    context "when domain_name_servers is nil" do
      before do
        subject.domain_name_servers = nil
      end

      it "returns an empty array" do
        expect(subject.domain_name_servers).to eq([])
      end
    end

    context "when domain_name_servers is not empty" do
      before do
        subject.domain_name_servers = "192.168.0.2,192.168.0.3"
      end

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  describe "#domain_name_servers=" do
    context "when the value is a string" do
      before do
        subject.domain_name_servers = "192.168.0.2,192.168.0.3"
      end

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end

    context "when the value is an string with whitespace" do
      subject { create :client_class, domain_name_servers: " 192.168.0.2, 192.168.0.3  " }

      it "stores the domain_name_servers correctly" do
        expect(subject.domain_name_servers).to eq(["192.168.0.2", "192.168.0.3"])
      end
    end
  end

  it "can only have 1 record in the database" do
    create(:client_class)

    new_client_class = build(:client_class)
    expect(new_client_class).to_not be_valid
    expect(new_client_class.errors[:base]).to include "A client class already exists"
  end
end
