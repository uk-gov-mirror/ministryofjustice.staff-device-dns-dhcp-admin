require "rails_helper"

describe UseCases::GenerateKeaConfig do
  describe "#execute" do
    it "returns a default subnet used for smoke testing" do
      config = UseCases::GenerateKeaConfig.new.execute

      expect(config.dig(:Dhcp4, :subnet4)).to match_array([
        {
          pools: [
            {
              pool: "172.0.0.1 - 172.0.2.0"
            }
          ],
          subnet: "127.0.0.1/0",
          id: 1
        }
      ])
    end

    it "appends subnets to the subnet4 list" do
      site = build_stubbed(:site, fits_id: "FITSID01", name: "SITENAME01")
      subnet1 = build_stubbed(:subnet, cidr_block: "10.0.1.0/24", start_address: "10.0.1.1", end_address: "10.0.1.255", site: site)
      subnet2 = build_stubbed(:subnet, cidr_block: "10.0.2.0/24", start_address: "10.0.2.1", end_address: "10.0.2.255", site: site)

      config = UseCases::GenerateKeaConfig.new(subnets: [subnet1, subnet2]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to match_array([
        {
          pools: [
            {
              pool: "172.0.0.1 - 172.0.2.0"
            }
          ],
          subnet: "127.0.0.1/0",
          id: 1
        },
        {
          pools: [
            {
              pool: "10.0.1.1 - 10.0.1.255"
            }
          ],
          subnet: "10.0.1.0/24",
          id: subnet1.kea_id,
          "user-context": {
            "site-id": subnet1.site.fits_id,
            "site-name": subnet1.site.name
          }
        },
        {
          pools: [
            {
              pool: "10.0.2.1 - 10.0.2.255"
            }
          ],
          subnet: "10.0.2.0/24",
          id: subnet2.kea_id,
          "user-context": {
            "site-id": subnet1.site.fits_id,
            "site-name": subnet1.site.name
          }
        }
      ])
    end

    it "returns a kea config with the correct keys" do
      config = UseCases::GenerateKeaConfig.new.execute
      expect(config).to have_key :Dhcp4
      expect(config[:Dhcp4].keys).to match_array([
        :"host-reservation-identifiers", :"hosts-database", :"interfaces-config",
        :"lease-database", :"valid-lifetime", :loggers, :subnet4
      ])
    end

    it "offsets the id to avoid collision with the reserved smoke testing subnet" do
      subnet1 = build_stubbed(:subnet, id: 1, cidr_block: "10.0.1.0/24")
      subnet2 = build_stubbed(:subnet, id: 2, cidr_block: "10.0.2.0/24")

      config = UseCases::GenerateKeaConfig.new(subnets: [subnet1, subnet2]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to match_array([
        hash_including(subnet: "127.0.0.1/0", id: 1),
        hash_including(subnet: "10.0.1.0/24", id: 1001),
        hash_including(subnet: "10.0.2.0/24", id: 1002)
      ])
    end

    it "appends options to the subnet" do
      option = build_stubbed(:option, routers: nil)

      config = UseCases::GenerateKeaConfig.new(subnets: [option.subnet]).execute

      expect(config.dig(:Dhcp4, :subnet4)).to include(hash_including({
        "option-data": [
          {
            "name": "domain-name-servers",
            "data": option.domain_name_servers.join(", ")
          },
          {
            "name": "domain-name",
            "data": option.domain_name
          }
        ]
      }))
    end
  end
end
