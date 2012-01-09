class OrdersController < ApplicationController
  before_filter :authenticate_user!

  # GET /orders
  # GET /orders.xml
  def index
    if(current_user.is_admin?)
      @orders = Order.all
    else
      @orders = current_user.orders
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = Order.find(params[:id])
    @requests = @order.requests
    @bill_addr = Address.new
    @ship_addr = Address.new

    if(current_user.is_admin? || @order.user == current_user)
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @order }
      end
    else
      redirect_to(orders_url)
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    @order = Order.new
    @order.user = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    if(@order.user != current_user && !current_user.is_admin?)
      redirect_to(orders_url)
    end
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = Order.new(params[:order])
    @user = current_user

    respond_to do |format|
      if @order.save
        format.html { redirect_to(@order, :notice => 'Order was successfully created.') }
        format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.xml
  def update
    @order = Order.find(params[:id])
    if(@order.user == current_user || current_user.is_admin?)
      respond_to do |format|
        if @order.update_attributes(params[:order])
          format.html { redirect_to(@order, :notice => 'Order was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_to(orders_url)
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    if(@order.user == current_user || current_user.is_admin?)
      @order.destroy
    end

    respond_to do |format|
      format.html { redirect_to(orders_url) }
      format.xml  { head :ok }
    end
  end
end
