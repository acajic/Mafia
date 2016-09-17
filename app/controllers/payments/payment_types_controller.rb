class Payments::PaymentTypesController < ApplicationController

  # GET /payments
  # GET /payments.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def index
    render json: PaymentType.all
  end
end
