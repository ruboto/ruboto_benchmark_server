class MeasurementsController < ApplicationController
  def index
    @measurements = Measurement.order('created_at DESC').all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @measurements }
    end
  end

  def show
    @measurement = Measurement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @measurement }
    end
  end

  def new
    @measurement = Measurement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @measurement }
    end
  end

  def edit
    @measurement = Measurement.find(params[:id])
  end

  def create
    @measurement = Measurement.new(params[:measurement])
    if Measurement.exists? params[:measurement]
      redirect_to :action => :index
      return
    end

    respond_to do |format|
      if @measurement.save
        format.html { redirect_to(@measurement, :notice => 'Measurement was successfully created.') }
        format.xml  { render :xml => @measurement, :status => :created, :location => @measurement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @measurement.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @measurement = Measurement.find(params[:id])

    respond_to do |format|
      if @measurement.update_attributes(params[:measurement])
        format.html { redirect_to(@measurement, :notice => 'Measurement was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @measurement.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @measurement = Measurement.find(params[:id])
    @measurement.destroy

    respond_to do |format|
      format.html { redirect_to(measurements_url) }
      format.xml  { head :ok }
    end
  end

  def top_ten
    @groups = Measurement.all.group_by{|s| [s.manufacturer, s.model, s.android_version, s.ruboto_app_version, s.ruboto_platform_version, s.package_version]}
    @rows = @groups.map do |group, measurements|
      [measurements.sort_by(&:duration)[(measurements.size / 4).to_i].duration] + group
    end.sort_by{|r| r[0]}
  end

end
