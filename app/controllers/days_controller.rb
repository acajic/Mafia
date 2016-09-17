class DaysController < ApplicationController

  RESOURCE = 'Day'

  resource_description do
    short "When one day and one night pass inside one game, that constitutes a #{RESOURCE}."
    formats ['json']
    param_group :auth_optional, ApipieParams::Auth
    description "When one day and one night pass inside one game, that constitutes a #{RESOURCE}. Each #{RESOURCE} belongs to a city. A city has many #{RESOURCE.pluralize()}."
  end

  # GET /days
  # GET /days.json
  before_filter(:only => :index) { |controller| controller.send(:confirm_authorization, [AppPermission::ADMIN_READ]) }
  api :GET, '/days', "Query #{RESOURCE.pluralize()}."
  description "Query #{RESOURCE.pluralize()}."
  param :city_name, String, :required => false, :desc => "#{RESOURCE.pluralize()} whose cities' names contain this string will be returned."
  param :number_min, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} with higher ordinal than specified will be returned."
  param :number_max, Integer, :required => false, :desc => "#{RESOURCE.pluralize()} with lower ordinal than this will be returned."
  param :created_at_min, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created after this timestamp will be returned."
  param :created_at_max, :Timestamp, :required => false, :desc => "Only #{RESOURCE.pluralize()} that were created before this timestamp will be returned."
  param :page_index, Integer, :required => false, :desc => "Page index."
  param :page_size, Integer, :required => false, :desc => "Page size."
  show false
  def index
    @days = Day.joins(:city).all

    unless params[:city_name].nil? || params[:city_name].empty?
      @days = @days.where("cities.name LIKE '%#{params[:city_name]}%'")
    end

    unless params[:number_min].nil? || params[:number_min].empty?
      @days = @days.where('days.number >= ?', params[:number_min].to_i())
    end

    unless params[:number_max].nil? || params[:number_max].empty?
      @days = @days.where('days.number <= ?', params[:number_max].to_i())
    end

    unless params[:created_at_min].nil? || params[:created_at_min].empty?
      @days = @days.where('days.created_at >= ?', Time.at(params[:created_at_min].to_i()).to_datetime())
    end

    unless params[:created_at_max].nil? || params[:created_at_max].empty?
      @days = @days.where('days.created_at <= ?', Time.at(params[:created_at_max].to_i()).to_datetime())
    end

    unless params[:page_index].nil? || params[:page_size].nil?
      page_index = params[:page_index].to_i()
      page_size = params[:page_size].to_i()
      @days = @days.limit(page_size).offset(page_size*page_index)
    end

    render json: @days
  end

end
