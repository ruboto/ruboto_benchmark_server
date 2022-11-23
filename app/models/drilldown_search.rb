# frozen_string_literal: true

class DrilldownSearch
  extend ActiveModel::Naming

  module DisplayType
    BAR = 'BAR'
    LINE = 'LINE'
    NONE = 'NONE'
    PIE = 'PIE'
  end

  module SelectValue
    COUNT = 'COUNT'
    VOLUME = 'VOLUME'
  end

  attr_reader :dimensions, :display_type, :fields, :filter, :last_change_time, :order_by_value, :select_value, :title,
              :default_fields
  attr_accessor :list, :percent

  def initialize(attributes_or_search, default_fields = nil)
    if attributes_or_search.is_a? DrilldownSearch
      s = attributes_or_search
      @dimensions = s.dimensions.dup
      @display_type = s.display_type.dup
      @fields = s.fields.dup
      @filter = s.filter.dup
      @list = s.list
      @percent = s.percent
      @last_change_time = s.last_change_time
      @order_by_value = s.order_by_value
      @select_value = s.select_value.dup
      @title = s.title
      @default_fields = s.default_fields
    else
      attributes = attributes_or_search
      @default_fields = default_fields
      @dimensions = (attributes && attributes[:dimensions]) || []
      @dimensions.delete_if(&:empty?)
      @filter = attributes && attributes[:filter] ? attributes[:filter] : {}
      @filter.each { |_k, v| v.delete('') }
      @filter.delete_if { |_k, v| v.empty? }
      @display_type = attributes && attributes[:display_type] ? attributes[:display_type] : DisplayType::NONE
      @display_type = DisplayType::BAR if @dimensions.size >= 2 && @display_type == DisplayType::PIE

      @order_by_value = attributes && (attributes[:order_by_value] == '1')
      @select_value = attributes && attributes[:select_value] && !attributes[:select_value].empty? ? attributes[:select_value] : SelectValue::COUNT
      @list = (attributes && attributes[:list] && attributes[:list] == '1') || false
      @percent = attributes.try(:[], :percent) == '1' || false
      @last_change_time = (attributes && attributes[:last_change_time] && attributes[:last_change_time] == '1') || false
      @fields = if attributes && attributes[:fields]
                  if attributes[:fields].is_a?(Array)
                    attributes[:fields]
                  else
                    attributes[:fields].select { |_k, v| v == '1' }.map { |k, _v| k }
                  end
                else
                  @default_fields
                end
      @title = attributes[:title] if attributes && attributes[:title] && !attributes[:title].empty?
    end
  end

  def url_options
    o = {
      drilldown_search: {
        title:,
        list: list ? '1' : '0',
        percent: percent ? '1' : '0',
        last_change_time: last_change_time ? '1' : '0',
        filter:,
        dimensions:,
        display_type:
      }
    }
    o[:drilldown_search][:fields] = fields unless fields == @default_fields
    o
  end

  # Used for DOM id
  def id
    'SEARCH'
  end

  def drill_down(dimensions, *values)
    raise 'Too many values' if values.size > self.dimensions.size

    s = DrilldownSearch.new(self)
    values.each_with_index { |v, i| s.filter[dimensions[i][:url_param_name]] = [v] }
    values.size.times { s.dimensions.shift }
    s
  end

  def to_key
    url_options.to_a
  end
end
