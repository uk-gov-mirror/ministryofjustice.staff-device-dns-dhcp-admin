describe UseCases::PublishKeaConfig do
  subject(:use_case) do
    described_class.new(
      destination_gateway: s3_gateway,
      generate_config: generate_config
    )
  end

  let(:generate_config) do
    double(
      execute: config
    )
  end
  let(:s3_gateway) { instance_spy(Gateways::S3) }
  let(:config) do
    '{ some: "json" }'
  end

  before do
    use_case.execute
  end

  it "publishes the Kea config" do
    expect(s3_gateway).to have_received(:write)
      .with(data: config)
  end
end
