class RecordsController < ApplicationController
  respond_to :json, :xml

  def index
    @records = domain.records
    respond_with @records
  end

  def show
    @record = domain.records.find(params[:id])
    respond_with @record
  end

  def create
    if request.content_type == Mime::JSON
      @record = domain.records.build
      consume!(@record)
    else
      @record = domain.records.create(params[:domain])
    end

    respond_with domain, @record
  end

  def update
    @record = domain.records.find(params[:id])

    if [Mime::JSON, Mime::XML].include? request.format
      consume!(@record)
    else
      @record.update_attributes(params[:record])
    end
    respond_with @record
  end

  def destroy
    @record = domain.records.find(params[:id])
    @record.destroy
    respond_with @record
  end

protected
  def domain
    @domain ||= Domain.find_by_name!(params[:domain_id])
  end
  helper_method :domain
end
