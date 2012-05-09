class DomainsController < ApplicationController
  respond_to :html
  respond_to :json, :xml, :only => [:index, :create, :show, :update, :delete]

  has_scope :page, :default => 1, :only => :index
  has_scope :per, :as => :limit, :default => 25, :only => :index
  includeable :records

  def index
    @domains = apply_scopes(Domain).order(:name)
    respond_with @domains
  end

  def show
    @domain = Domain.find_by_slug!(params[:id])
    respond_with @domain
  end

  def new
    @domain = Domain.new(params[:domain])
    respond_with @domain
  end

  def create
    if [Mime::JSON, Mime::XML].include? request.format
      @domain = Domain.new
      consume!(@domain)
    else
      @domain = Domain.create(params[:domain])
    end
    respond_with @domain
  end

  def edit
    @domain = Domain.find_by_slug!(params[:id])
    respond_with @domain
  end

  def update
    @domain = Domain.find_by_slug!(params[:id])

    if [Mime::JSON, Mime::XML].include? request.format
      @domain = Domain.new
      consume!(@domain)
    else
      @domain.update_attributes(params[:domain])
    end

    respond_with @domain
  end

  def destroy
    @domain = Domain.find_by_slug!(params[:id])
    @domain.destroy
    respond_with @domain
  end
end