class Purchases::RolePickPurchasesController < ApplicationController

  # GET /role_pick_purchases
  # GET /role_pick_purchases.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    role_pick_purchases = RolePickPurchase.joins('LEFT JOIN users ON role_pick_purchases.user_id = users.id').joins('LEFT JOIN role_picks ON role_pick_purchases.role_pick_id = role_picks.id').all

    unless params[:username].blank?
      role_pick_purchases = role_pick_purchases.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:user_email].blank?
      role_pick_purchases = role_pick_purchases.where("role_pick_purchases.user_email LIKE '%#{params[:user_email]}%'")
    end

    if params[:role_ids]
      if params[:is_fulfilled].blank?
        role_pick_purchases = role_pick_purchases.where('role_picks.role_id IN (?) OR role_picks.role_id IS NULL', params[:role_ids])
      elsif params[:is_fulfilled] == 'true'
        role_pick_purchases = role_pick_purchases.where('role_picks.role_id IN (?)', params[:role_ids])
      end

    end

    unless params[:is_fulfilled].blank?
      if params[:is_fulfilled] == 'true'
        role_pick_purchases = role_pick_purchases.where('role_picks.city_id IS NOT NULL')
      else
        role_pick_purchases = role_pick_purchases.where('role_picks.city_id IS NULL')
      end

    end

    unless params[:city_name].blank?
      role_pick_purchases = role_pick_purchases.where("role_picks.city_name LIKE '%#{params[:city_name]}%'")
    end

    unless params[:city_started_at_min].blank?
      role_pick_purchases = role_pick_purchases.where('role_picks.city_started_at >= ?', Time.at(params[:city_started_at_min].to_i()).to_datetime())
    end

    unless params[:city_started_at_max].blank?
      role_pick_purchases = role_pick_purchases.where('role_picks.city_started_at <= ?', Time.at(params[:city_started_at_max].to_i()).to_datetime())
    end

    unless params[:created_at_min].blank?
      role_pick_purchases = role_pick_purchases.where('role_pick_purchases.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].blank?
      role_pick_purchases = role_pick_purchases.where('role_pick_purchases.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    role_pick_purchases.order!('role_pick_purchases.id DESC')

    if params[:page_index] && params[:page_size]
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      role_pick_purchases = role_pick_purchases.limit(page_size).offset(page_size*page_index)
    end

    render json: role_pick_purchases
  end


  # GET /role_pick_purchases/1
  # GET /role_pick_purchases/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def show
    role_pick_purchase = RolePickPurchase.find(params.require(:id))

    render json: role_pick_purchase
  end

  # GET /role_pick_purchases/new
  # GET /role_pick_purchases/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def new
    new_role_pick_purchase = RolePickPurchase.new()

    render json: new_role_pick_purchase
  end


  # POST /role_pick_purchases
  # POST /role_pick_purchases.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def create

    role_pick_purchase_hash = params.require(:role_pick_purchase)

    role_pick_purchase_hash = RolePickPurchase.init_hash(role_pick_purchase_hash)

    role_pick_purchase = RolePickPurchase.new(role_pick_purchase_hash)

    if role_pick_purchase.save()
      render json: role_pick_purchase, :status => :created
    else
      render json: role_pick_purchase.errors, :status => :unprocessable_entity
    end
  end


  # PUT /role_pick_purchases/1
  # PUT /role_pick_purchases/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def update
    role_pick_purchase = RolePickPurchase.find(params.require(:id))

    role_pick_purchase_hash = params.require(:role_pick_purchase)

    role_pick_purchase_hash = RolePickPurchase.init_hash(role_pick_purchase_hash)

    if role_pick_purchase.update_attributes(role_pick_purchase_hash)
      render json: role_pick_purchase, :status => :ok
    else
      render json: role_pick_purchase.errors, :status => :unprocessable_entity
    end
  end


  # DELETE /role_pick_purchases/1
  # DELETE /role_pick_purchases/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def destroy
    role_pick_purchase = RolePickPurchase.find(params.require(:id))

    role_pick_purchase.destroy()
    head :no_content
  end


end
