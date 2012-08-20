class MeasurementsDrilldownController < DrilldownController
  FIELDS = {
      :android_version => {},
      :compile_mode => {},
      :duration => {},
      :manufacturer => {},
      :model => {},
      :package => {},
      :package_version => {},
      :ruboto_app_version => {},
      :ruboto_platform_version => {},
      :ruby_version => {},
      :test => {},
      :time => {},
  }

  DEFAULT_FIELDS = %w{time duration package package_version test manufacturer model ruboto_platform_version ruboto_app_version android_version}
  TARGET_CLASS = Measurement
  SELECT = "AVG(duration) as volume, sum(1) as count"
  LIST_INCLUDES = []
  LIST_ORDER = nil # 'fuel_imports.imported_at'

  def initialize
    super(FIELDS, DEFAULT_FIELDS, TARGET_CLASS, SELECT, nil, [], LIST_INCLUDES, LIST_ORDER)
    @dimension_defs = {}

    #dimension :calendar_date, "DATE(measurements.created_at AT TIME ZONE 'CET0')", :interval => true
    dimension :calendar_date, "DATE(measurements.created_at)", :interval => true
    #dimension :day_of_month, "date_part('day', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :day_of_week, "CASE WHEN date_part('dow', fuel_imports.imported_at AT TIME ZONE 'CET0') = 0 THEN 7 ELSE date_part('dow', fuel_imports.imported_at AT TIME ZONE 'CET0') END",
    #          :label_method => lambda { |day_no| Date::DAYNAMES[day_no.to_i % 7] }
    #dimension :hour_of_day, "date_part('hour', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :month, "date_part('month', fuel_imports.imported_at AT TIME ZONE 'CET0')",
    #          :label_method => lambda { |month_no| Date::MONTHNAMES[month_no.to_i] }
    #dimension :week, "date_part('week', fuel_imports.imported_at AT TIME ZONE 'CET0')"
    #dimension :year, "date_part('year', fuel_imports.imported_at AT TIME ZONE 'CET0')"

    dimension :android_version, :android_version
    dimension :compile_mode, :compile_mode
    dimension :manufacturer, :manufacturer
    dimension :model, :model
    dimension :package, :package
    dimension :package_version, :package_version
    dimension :ruboto_app_version, :ruboto_app_version
    dimension :ruboto_platform_version, :ruboto_platform_version
    dimension :ruby_version, :ruby_version
    dimension :test, :test
  end

end
