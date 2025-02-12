class OptionsController < ApplicationController
  before_action :set_subnet
  before_action :set_option, only: [:edit, :update, :destroy]

  def new
    @option = @subnet.build_option
    authorize! :create, @option
    @global_option = GlobalOption.first
  end

  def create
    @option = @subnet.build_option(option_params)
    authorize! :create, @option

    if update_dhcp_config.call(@option, -> { @option.save })
      redirect_to subnet_path(@option.subnet), notice: "Successfully created options." + CONFIG_UPDATE_DELAY_NOTICE
    else
      @global_option = GlobalOption.first
      render :new
    end
  end

  def edit
    authorize! :update, @option
    @global_option = GlobalOption.first
  end

  def update
    authorize! :update, @option
    @option.assign_attributes(option_params)

    if update_dhcp_config.call(@option, -> { @option.save })
      redirect_to subnet_path(@option.subnet), notice: "Successfully updated options." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @option
    if confirmed?
      if update_dhcp_config.call(@option, -> { @option.destroy })
        redirect_to subnet_path(@option.subnet), notice: "Successfully deleted option." + CONFIG_UPDATE_DELAY_NOTICE
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
    params.require(:option).permit(:domain_name_servers, :domain_name, :valid_lifetime, :valid_lifetime_unit)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
