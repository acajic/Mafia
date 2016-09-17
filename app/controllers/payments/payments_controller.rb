class Payments::PaymentsController < ApplicationController


  # GET /payments
  # GET /payments.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index

    payment_logs = PaymentLog.joins('LEFT JOIN users ON payment_logs.user_id = users.id').all

    unless params[:username].blank?
      payment_logs = payment_logs.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:user_email].blank?
      payment_logs = payment_logs.where("payment_logs.user_email LIKE '%#{params[:user_email]}%'")
    end

    if params[:payment_type_ids]
      payment_logs = payment_logs.where(:payment_type_id => params[:payment_type_ids])
    end

    unless params[:unit_price_min].blank?
      payment_logs = payment_logs.where('payment_logs.unit_price >= ?', params[:unit_price_min].to_f())
    end

    unless params[:unit_price_max].blank?
      payment_logs = payment_logs.where('payment_logs.unit_price <= ?', params[:unit_price_max].to_f())
    end

    unless params[:quantity_min].blank?
      payment_logs = payment_logs.where('payment_logs.quantity >= ?', params[:quantity_min].to_i())
    end

    unless params[:quantity_max].blank?
      payment_logs = payment_logs.where('payment_logs.quantity <= ?', params[:quantity_max].to_i())
    end

    unless params[:total_price_min].blank?
      payment_logs = payment_logs.where('payment_logs.total_price >= ?', params[:total_price_min].to_f())
    end

    unless params[:total_price_max].blank?
      payment_logs = payment_logs.where('payment_logs.total_price <= ?', params[:total_price_max].to_f())
    end

    unless params[:is_payment_valid].blank?
      payment_logs = payment_logs.where(:is_payment_valid => params[:is_payment_valid] == 'true')
    end

    unless params[:info_json].blank?
      payment_logs = payment_logs.where("payment_logs.info_json LIKE '%#{params[:info_json]}%'")
    end

    unless params[:created_at_min].blank?
      payment_logs = payment_logs.where('payment_logs.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].blank?
      payment_logs = payment_logs.where('payment_logs.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    payment_logs.order!('payment_logs.id DESC')

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      payment_logs = payment_logs.limit(page_size).offset(page_size*page_index)
    end



    render json: payment_logs

  end


  # GET /payments/new
  # GET /payments/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def new
    new_payment_log = PaymentLog.new()
    new_payment_log.payment_type = PaymentType.find(PaymentType::UNKNOWN)
    render json: new_payment_log
  end

  # GET /payments/1
  # GET /payments/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def show
    payment_log_id = params.require(:id)
    payment_log = PaymentLog.find(payment_log_id)

    render json: payment_log
  end


  # POST /payments
  # POST /payments.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def create

    payment_log_hash = params.require(:payment_log)

    payment_log_hash = PaymentLog.init_hash(payment_log_hash)

    new_payment_log = PaymentLog.new(payment_log_hash)
    if new_payment_log.save()
      render json: new_payment_log, :status => :created
    else
      render json: new_payment_log.errors, :status => :unprocessable_entity
    end

  end

  # PUT /payments/1
  # PUT /payments/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def update
    payment_log_id = params.require(:id)
    payment_log = PaymentLog.find(payment_log_id)

    payment_log_hash = params.require(:payment_log)

    payment_log_hash = PaymentLog.init_hash(payment_log_hash)

    if payment_log.update_attributes(payment_log_hash)
      render json: payment_log
    else
      render json: payment_log.errors, :status => :unprocessable_entity
    end

  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def destroy
    payment_log_id = params.require(:id)
    payment_log = PaymentLog.find(payment_log_id)

    payment_log.destroy()
    head :no_content
  end

end
