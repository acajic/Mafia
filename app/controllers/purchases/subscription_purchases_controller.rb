class Purchases::SubscriptionPurchasesController < ApplicationController


  # GET /subscription_purchases
  # GET /subscription_purchases.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    subscription_purchases = SubscriptionPurchase.joins('LEFT JOIN users ON subscription_purchases.user_id = users.id').all


    unless params[:username].blank?
      subscription_purchases = subscription_purchases.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:user_email].blank?
      subscription_purchases = subscription_purchases.where("subscription_purchases.user_email LIKE '%#{params[:user_email]}%'")
    end

    if params[:subscription_types]
      subscription_purchases = subscription_purchases.where(:subscription_type => params[:subscription_types])
    end

    unless params[:expiration_date_min].blank?
      subscription_purchases = subscription_purchases.where('subscription_purchases.expiration_date >= ?', Time.at(params[:expiration_date_min].to_i()).to_datetime())
    end

    unless params[:expiration_date_max].blank?
      subscription_purchases = subscription_purchases.where('subscription_purchases.expiration_date <= ?', Time.at(params[:expiration_date_max].to_i()).to_datetime())
    end

    unless params[:active].blank?
      if params[:active] == 'true'
        subscription_purchases = subscription_purchases.where('subscription_purchases.expiration_date > ?', Time.now.to_datetime())
      else
        subscription_purchases = subscription_purchases.where('subscription_purchases.expiration_date <= ?', Time.now.to_datetime())
      end
    end

    unless params[:created_at_min].blank?
      subscription_purchases = subscription_purchases.where('subscription_purchases.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].blank?
      subscription_purchases = subscription_purchases.where('subscription_purchases.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    subscription_purchases.order!('subscription_purchases.id DESC')

    if params[:page_index] && params[:page_size]
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      subscription_purchases = subscription_purchases.limit(page_size).offset(page_size*page_index)
    end

    render json: subscription_purchases
  end


  # GET /subscription_purchases/1
  # GET /subscription_purchases/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def show
    subscription_purchase = SubscriptionPurchase.find(params.require(:id))

    render json: subscription_purchase
  end

  # GET /subscription_purchases/new
  # GET /subscription_purchases/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def new
    new_subscription_purchase = SubscriptionPurchase.new()
    new_subscription_purchase.subscription_type = SubscriptionPurchase::TYPE_1_MONTH

    render json: new_subscription_purchase
  end


  # POST /subscription_purchases
  # POST /subscription_purchases.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def create
    subscription_purchase_hash = params.require(:subscription_purchase)

=begin

    payment_log = nil
    if subscription_purchase_hash[:should_create_payment_log]
      subscription_type = subscription_purchase_hash.require(:subscription_type)
      payment_type_id = case subscription_type
        when SubscriptionPurchase::TYPE_1_MONTH then PaymentType::SUBSCRIPTION_1_MONTH
        when SubscriptionPurchase::TYPE_1_YEAR then PaymentType::SUBSCRIPTION_1_YEAR
        else PaymentType::UNKNOWN
                     end

      if payment_type_id == PaymentType::UNKNOWN
        render json: 'Unknown subscription type', :status => :unprocessable_entity
        return false
      end

      payment_log_hash = subscription_purchase_hash[:payment_log]

      payment_log = PaymentLog.new(:user_id => payment_log_hash.require(:user).require(:id), :payment_type_id => payment_type_id, :quantity => payment_log_hash.require(:quantity), :unit_price => payment_log_hash.require(:unit_price))

    end

=end

    subscription_purchase_hash = SubscriptionPurchase.init_hash(subscription_purchase_hash)



    subscription_purchase = SubscriptionPurchase.new(subscription_purchase_hash)
    if subscription_purchase.save()
      render json: subscription_purchase, :status => :created
    else
      render json: subscription_purchase.errors, :status => :unprocessable_entity
    end

  end


  # PUT /subscription_purchases/1
  # PUT /subscription_purchases/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def update
    subscription_purchase = SubscriptionPurchase.find(params.require(:id))

    subscription_purchase_hash = params.require(:subscription_purchase)

    subscription_purchase_hash = SubscriptionPurchase.init_hash(subscription_purchase_hash)

    if subscription_purchase.update_attributes(subscription_purchase_hash)
      render json: subscription_purchase, :status => :ok
    else
      render json: subscription_purchase.errors, :status => :unprocessable_entity
    end
  end


  # DELETE /subscription_purchases/1
  # DELETE /subscription_purchases/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def destroy
    subscription_purchase = SubscriptionPurchase.find(params.require(:id))

    subscription_purchase.destroy()
    head :no_content
  end


end
