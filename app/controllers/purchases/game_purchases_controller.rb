class Purchases::GamePurchasesController < ApplicationController

  # GET /game_purchases
  # GET /game_purchases.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def index
    game_purchases = GamePurchase.joins('LEFT JOIN users ON game_purchases.user_id = users.id').joins('LEFT JOIN cities ON game_purchases.city_id = cities.id')

    unless params[:username].blank?
      game_purchases = game_purchases.where("users.username LIKE '%#{params[:username]}%'")
    end

    unless params[:user_email].blank?
      game_purchases = game_purchases.where("game_purchases.user_email LIKE '%#{params[:user_email]}%'")
    end


    unless params[:used].blank?
      if params[:used] == 'true'
        game_purchases = game_purchases.where('game_purchases.city_id IS NOT NULL')
      else
        game_purchases = game_purchases.where('game_purchases.city_id IS NULL')
      end

    end

    unless params[:city_name].blank?
      game_purchases = game_purchases.where("game_purchases.city_name LIKE '%#{params[:city_name]}%'")
    end

    unless params[:city_started_at_min].blank?
      game_purchases = game_purchases.where('game_purchases.city_started_at >= ?', Time.at(params[:city_started_at_min].to_i()).to_datetime())
    end

    unless params[:city_started_at_max].blank?
      game_purchases = game_purchases.where('game_purchases.city_started_at <= ?', Time.at(params[:city_started_at_max].to_i()).to_datetime())
    end


    unless params[:created_at_min].blank?
      game_purchases = game_purchases.where('game_purchases.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].blank?
      game_purchases = game_purchases.where('game_purchases.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    game_purchases.order!('game_purchases.id DESC')

    if params[:page_index] && params[:page_size]
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      game_purchases = game_purchases.limit(page_size).offset(page_size*page_index)
    end


    render json: game_purchases
  end


  # GET /game_purchases/1
  # GET /game_purchases/1.json
  before_filter(:only => :show) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def show
    game_purchase = GamePurchase.find(params.require(:id))

    render json: game_purchase
  end

  # GET /game_purchases/new
  # GET /game_purchases/new.json
  before_filter(:only => :new) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  def new
    new_game_purchase = GamePurchase.new()

    render json: new_game_purchase
  end


  # POST /game_purchases
  # POST /game_purchases.json
  before_filter(:only => :create) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def create

    game_purchase_hash = params.require(:game_purchase)

    game_purchase_hash = GamePurchase.init_hash(game_purchase_hash)

    game_purchase = GamePurchase.new(game_purchase_hash)


    if game_purchase.save()
      render json: game_purchase, :status => :created
    else
      render json: game_purchase.errors, :status => :unprocessable_entity
    end
  end


  # PUT /game_purchases/1
  # PUT /game_purchases/1.json
  before_filter(:only => :update) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def update
    game_purchase = GamePurchase.find(params.require(:id))

    game_purchase_hash = params.require(:game_purchase)

    game_purchase_hash = GamePurchase.init_hash(game_purchase_hash)

    if game_purchase.update_attributes(game_purchase_hash)
      render json: game_purchase, :status => :ok
    else
      render json: game_purchase.errors, :status => :unprocessable_entity
    end
  end


  # DELETE /game_purchases/1
  # DELETE /game_purchases/1.json
  before_filter(:only => :destroy) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_WRITE]) }
  def destroy
    game_purchase = GamePurchase.find(params.require(:id))

    game_purchase.destroy()
    head :no_content
  end



end
