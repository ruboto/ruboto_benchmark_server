class MeasurementsDrilldownController < DrilldownController
  TRANSACTION_FIELDS = {
    #:batch_no => {},
    #:density => {:excel_type => 'Number',
    #  :excel_style => 'StandardNumberFormat'},
      :duration => {},
    #:from_tank => {},
    #:supplier => { :attr_method => lambda { |transaction| transaction.supplier.try(:name) },
    #  :join => :suppliers},
    #:temperature => {:excel_type => 'Number',
    #  :excel_style => 'StandardNumberFormat'},
    :time => {},
    #:to_tank => {},
    #:volume_abbr => { :attr_method => lambda { |transaction| transaction.volume },
    #  :excel_type => 'Number' },
    #:volume_compensated => {:excel_type => 'Number'},
  }

  DEFAULT_FIELDS = %w{time duration}
  TARGET_CLASS = Measurement
  SELECT = "AVG(duration) as duration, sum(1) as count"
  LIST_INCLUDES = []
  LIST_ORDER = nil # 'fuel_imports.imported_at'

  def initialize
    super(TRANSACTION_FIELDS, DEFAULT_FIELDS, TARGET_CLASS, SELECT, nil, [], LIST_INCLUDES, LIST_ORDER)
    @dimension_defs = {}

    #dimension :calendar_date, "DATE(measurements.created_at AT TIME ZONE 'CET0')", :interval => true
    dimension :calendar_date, "DATE(measurements.created_at)", :interval => true
    #dimension :day_of_month, "date_part('day', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :day_of_week, "CASE WHEN date_part('dow', fuel_imports.imported_at AT TIME ZONE 'CET0') = 0 THEN 7 ELSE date_part('dow', fuel_imports.imported_at AT TIME ZONE 'CET0') END",
    #          :label_method => lambda { |day_no| Date::DAYNAMES[day_no.to_i % 7] }
    #dimension :from_tank, 'from_tank'
    #dimension :hour_of_day, "date_part('hour', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :month, "date_part('month', fuel_imports.imported_at AT TIME ZONE 'CET0')",
    #          :label_method => lambda { |month_no| Date::MONTHNAMES[month_no.to_i] }
    #dimension :supplier, 'suppliers.name', :includes => :supplier
    #dimension :to_tank, 'to_tank'
    #dimension :week, "date_part('week', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :year, "date_part('year', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :source, :source

    dimension :package, :package
    dimension :package_version, :package_version
    dimension :manufacturer, :manufacturer
    dimension :model, :model
    dimension :android_version, :android_version
    dimension :ruboto_platform_version, :ruboto_platform_version
    dimension :ruboto_app_version, :ruboto_app_version
    dimension :test, :test
  end

end
