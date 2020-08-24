require "rails_helper"

describe "create subnets", type: :feature do
  before do
    login_as User.create
  end

  it "creates a new subnet" do
    visit "/subnets/new"

    fill_in "CIDR Block", with: "10.0.1.0/24"
    fill_in "Start Address", with: "10.0.1.1"
    fill_in "End Address", with: "10.0.1.255"

    click_button "Create"

    expect(current_path).to eq("/subnets")

    subnet = Subnet.last
    expect(subnet.cidr_block).to eq "10.0.1.0/24"
    expect(subnet.start_address).to eq "10.0.1.1"
    expect(subnet.end_address).to eq "10.0.1.255"
  end
end
