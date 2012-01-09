class RequestsController < ApplicationController
  before_filter :authenticate_user!

  # GET /requests
  # GET /requests.xml
  def index
    if(current_user.is_admin?)      
      @requests = Request.all
    else
      @requests = current_user.requests
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @requests }
    end
  end

  # GET /requests/1
  # GET /requests/1.xml
  def show
    @request = Request.find(params[:id])
    @address = @request.user.addresses.first

    respond_to do |format|
      format.html # show.html.erb
      format.svg
    end
  end

  # GET /requests/new
  # GET /requests/new.xml
  def new
    @request = Request.new
    @request.user = current_user
    @agencies = Agency.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @request }
    end
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
    if(@request.user != current_user && !current_user.is_admin?)
      redirect_to(:index)
    end
  end

  # POST /requests
  # POST /requests.xml
  def create
    @request = Request.new(params[:request])
    @request.user = current_user

    respond_to do |format|
      if @request.save
        format.html { redirect_to(@request, :notice => 'Request was successfully created.') }
        format.xml  { render :xml => @request, :status => :created, :location => @request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /requests/1
  # PUT /requests/1.xml
  def update
    @request = Request.find(params[:id])


    if(@request.user == current_user || !current_user.is_admin)
      respond_to do |format|
        if @request.update_attributes(params[:request])
          format.html { redirect_to(@request, :notice => 'Request was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @request.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.xml
  def destroy
    @request = Request.find(params[:id])

    if(@request.user == current_user || current_user.is_admin?)
      @request.destroy
    end

    respond_to do |format|
      format.html { redirect_to(requests_url) }
      format.xml  { head :ok }
    end
  end
end
