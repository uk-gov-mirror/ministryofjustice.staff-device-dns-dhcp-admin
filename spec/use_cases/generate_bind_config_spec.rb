require "rails_helper"

describe UseCases::GenerateBindConfig do
  let(:generated_config) { UseCases::GenerateBindConfig.new(zones: all_zones, pdns_ips: "7.7.7.7,5.5.5.5").call }

  describe "#call" do
    let(:all_zones) { [] }

    it "generates a BIND template with no dynamic zones" do
      expected_config = %(
options {
  directory "/var/bind";

  allow-recursion {
    any;
  };

  listen-on port 53 { any; };
  listen-on-v6 { none; };

  pid-file "/var/run/named/named.pid";

  dnssec-validation no;

  allow-transfer { none; };
  allow-query { any; };
};

statistics-channels {
  inet 127.0.0.1 port 8080 allow { 127.0.0.1; };
};

zone "localhost" IN {
  type master;
  file "pri/localhost.zone";
  allow-update { none; };
  notify no;
};

zone "127.in-addr.arpa" IN {
  type master;
  file "pri/127.zone";
  allow-update { none; };
  notify no;
};

zone "." IN {
  type forward;
  forward only;
  forwarders {
    7.7.7.7;
5.5.5.5;
    };
};
)
      expect(generated_config).to eq(expected_config)
    end
  end

  describe "Dynamic zones" do
    before do
      create(:zone, name: "example.test.com", forwarders: "127.0.0.1,127.0.0.2")
      create(:zone, name: "example2.test.com", forwarders: "10.0.0.1,10.0.0.255")
    end

    let(:all_zones) { Zone.all }

    it "Renders dynamic zones from the database" do
      expected_config = %(
zone "example.test.com" IN {
  type forward;
  forward only;
  forwarders {127.0.0.1;127.0.0.2;};
};

zone "example2.test.com" IN {
  type forward;
  forward only;
  forwarders {10.0.0.1;10.0.0.255;};
};
)
      expect(generated_config).to include(expected_config)
    end
  end

  describe "Unset pdns ips" do
    let(:generated_config) { UseCases::GenerateBindConfig.new(pdns_ips: "").call }

    it "raises an error when PDNS IPs have not been defined" do
      expect { generated_config }.to raise_error("PDNS IPs have not been set")
    end
  end
end
