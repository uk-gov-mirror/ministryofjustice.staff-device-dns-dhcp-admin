class OptionsController < ApplicationController
  before_action :set_subnet
  before_action :set_option, only: [:edit, :update, :destroy]

  def new
    @option = @subnet.build_option
    authorize! :create, @option
  end

  def create
    @option = @subnet.build_option(option_params)
    authorize! :create, @option
    if @option.save
      publish_kea_config
      deploy_dhcp_service
      redirect_to subnet_path(@option.subnet), notice: "Successfully created options"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @option
  end

  def update
    authorize! :update, @option
    if @option.update(option_params)
      publish_kea_config
      deploy_dhcp_service
      redirect_to subnet_path(@option.subnet), notice: "Successfully updated options"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @option
    if confirmed?
      if @option.destroy
        publish_kea_config
        deploy_dhcp_service
        redirect_to subnet_path(@option.subnet), notice: "Successfully deleted option"
      else
        redirect_to subnet_path(@option.subnet), error: "Failed to delete the option"
      end
    else
      render "destroy"
    end
  end

  private

  def subnet_id
    params.fetch(:subnet_id)
  end

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def set_option
    @option = @subnet.option
  end

  def option_params
    params.require(:option).permit(:routers, :domain_name_servers, :domain_name, :valid_lifetime)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def publish_kea_config
    UseCases::PublishKeaConfig.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("KEA_CONFIG_BUCKET"),
        key: "config.json",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "application/json"
      ),
      generate_config: UseCases::GenerateKeaConfig.new(subnets: Subnet.all)
    ).execute
  end
end
