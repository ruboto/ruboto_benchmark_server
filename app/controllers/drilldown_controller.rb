require 'drilldown_helper'

class DrilldownController < ApplicationController
  include DrilldownHelper

  def initialize(fields, default_fields, target_class, select, base_condition, base_includes, list_includes, list_order)
    super()
    @fields = fields
    @default_fields = default_fields
    @target_class = target_class
    @select = select
    @base_condition = base_condition
    @base_includes = base_includes
    @list_includes = list_includes
    @list_order = list_order
    @dimension_defs = {}
    @summary_fields = [:volume, :volume_compensated]
  end

  def xml_export
    params[:drilldown_search][:list] = '1'
    index(false)
    @transactions = get_transactions(@result)
    headers['Content-Type'] = "text/xml"
    headers['Content-Disposition'] = 'attachment; filename="transactions.xml"'
    render :template => '/drilldown/xml_export', :layout => false
  end

  # ?dimension[0]=supplier&dimension[1]=transaction_type&
  # filter[year]=2009&filter[supplier][0]=Shell&filter[supplier][1]=Statoil
  def index(do_render = true)
    @search = DrilldownSearch.new(params[:drilldown_search], @default_fields)

    @transaction_fields = (@search.fields + ((@fields.keys.map { |field_name| field_name.to_s }) - @search.fields))
    @transaction_fields_map = @fields

    select = @select.dup
    includes = @base_includes.dup

    @dimensions = []
    select << ", 'All' as value0"
    @dimensions += @search.dimensions.map do |dn|
      raise "Unknown distribution field: #{@search.dimensions.inspect}" if @dimension_defs[dn].nil?
      @dimension_defs[dn]
    end
    @dimensions.each_with_index do |d, i|
      select << ", #{d[:select_expression]} as value#{i + 1}"
      includes << d[:includes] if d[:includes]
    end

    conditions, @filter_text, filter_includes = make_conditions(@search.filter)
    includes += filter_includes
    includes.uniq!
    if @search.order_by_value && @dimensions.size <= 1
      order = @search.select_value == DrilldownSearch::SelectValue::VOLUME ? 'volume DESC' : 'count DESC'
    else
      order = @dimensions.map { |d| d[:select_expression] }.join(', ')
      order = nil if order.empty?
    end
    group = @dimensions.map { |d| d[:select_expression] }.join(', ')
    group = nil if group.empty?

    rows = @target_class.where(@base_condition).select(select).where(conditions).
        joins(make_join([], @target_class.name.underscore.to_sym, includes)).
        group(group).
        order(order).all

    if rows.empty?
      @result = {:value => "All", :count => 0, :volume => 0, :volume_compensated => 0, :row_count => 0, :nodes => 0, :rows => []}
    else
      @result = result_from_rows(rows, 0, 0, ['All'])
    end
    @search.list = false if @result[:count] > 10000

    @remaining_dimensions = @dimension_defs.dup.delete_if { |dim_name, dimension| @search.filter[dim_name] && @search.filter[dim_name].size == 1 }
    populate_list(conditions, includes, @result, []) if @search.list
    render :template => '/drilldown/index' if do_render
  end

  # Empty summary rows are needed to plot zero points in the charts
  def add_zero_results(result_rows, dimension)
    legal_values = legal_values_for(@dimensions[dimension][:url_param_name], true).call(@search).map { |lv| lv[1] }
    current_values = result_rows.map { |r| r[:value] }.compact
    empty_values = legal_values - current_values

    unless empty_values.empty?
      empty_values.each do |v|
        sub_result = {
            :value => v,
            :count => 0,
            :volume => 0,
            :volume_compensated => 0,
            :row_count => 0,
            :nodes => 0,
        }
        if dimension < @dimensions.size - 1
          sub_result[:rows] = add_zero_results([], dimension + 1)
        end
        result_rows << sub_result
      end
      result_rows = result_rows.sort_by { |r| legal_values.index(r[:value]) }
    end
    result_rows
  end

  def result_from_rows(rows, row_index, dimension, previous_values)
    row = rows[row_index]
    return nil if row.nil?
    values = (0..dimension).to_a.map { |i| row["value#{i}"] }
    return nil if values != previous_values

    if dimension == @dimensions.size
      return {
          :value => values[-1],
          :count => row[:count].to_i,
          :volume => row[:volume].to_i,
          :volume_compensated => row[:volume_compensated].to_i,
          :row_count => 1,
          :nodes => @search.list ? 2 : 1,
      }
    end

    result_rows = []
    loop do
      sub_result = result_from_rows(rows, row_index, dimension + 1, values + [rows[row_index]["value#{dimension + 1}"]])
      break if sub_result.nil?
      result_rows << sub_result
      row_index += sub_result[:row_count]
      break if rows[row_index].nil?
    end

    result_rows = add_zero_results(result_rows, dimension)

    total_count = result_rows.inject(0) { |t, r| t + r[:count].to_i }
    {
        :value => values[-1],
        :count => total_count,
        :volume => result_rows.inject(0){ |t, r| t + r[:volume]} / total_count,
        :volume_compensated => result_rows.inject(0){ |t, r| t + r[:volume_compensated]} / total_count,
        :row_count => result_rows.inject(0) { |t, r| t + r[:row_count] },
        :nodes => result_rows.inject(0) { |t, r| t + r[:nodes] } + 1,
        :rows => result_rows,
    }
  end

  def html_export
    index(false)
    render :template => '/drilldown/html_export', :layout => 'print'
  end

  def excel_export
    index(false)
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="transactions.xml"'
    headers['Cache-Control'] = ''
    render :template => '/drilldown/excel_export', :layout => false
  end

  def excel_export_transactions
    params[:drilldown_search][:list] = '1'
    index(false)
    @transactions = get_transactions(@result)
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="transactions.xml"'
    render :template => '/drilldown/excel_export_transactions', :layout => false
  end

  private

  def populate_list(conditions, includes, result, values)
    if result[:rows]
      result[:rows].each do |r|
        populate_list(conditions, includes, r, values + [r[:value]])
      end
    else
      options = {:include => includes + @list_includes, :order => @list_order}
      @search.fields.each do |field|
        field_def = @transaction_fields_map[field.to_sym]
        raise "Field definition missing for: #{field.inspect}" unless field_def
        field_includes = field_def[:include]
        if field_includes
          options[:include] += field_includes.is_a?(Array) ? field_includes : [field_includes]
        end
      end
      options[:include].uniq!
      if @search.last_change_time
        options[:include] << {:assignment => {:order => :last_aircraft_registration_change}} if @search.fields.include? 'aircraft_registration'
        options[:include] << {:assignment => {:order => :last_fuel_request_change}} if @search.fields.include? 'fuel_request'
      end
      joins = make_join([], @target_class.name.underscore.to_sym, options.delete(:include))
      result[:transactions] = @target_class.joins(joins).where(@base_condition).all(options.update(:conditions => list_conditions(conditions, values)))
    end
  end

  def list_conditions(conditions, values)
    list_conditions_string = conditions[0].dup
    @dimensions.each do |d|
      list_conditions_string << "#{' AND ' unless list_conditions_string.empty?}#{d[:select_expression]} = ?"
    end
    [list_conditions_string, *(conditions[1..-1] + values)]
  end

  def make_conditions(search_filter)
    includes = @base_includes.dup
    if search_filter
      condition_strings = []
      condition_values = []

      filter_texts = []
      search_filter.each do |field, values|
        dimension_def = @dimension_defs[field]
        raise "Unknown filter field: #{field.inspect}" if dimension_def.nil?
        values = [*values]
        if dimension_def[:interval]
          values *= 2 if values.size == 1
          raise "Need 2 values for interval filter: #{values.inspect}" if values.size != 2
          if !values[0].blank? && !values[1].blank?
            condition_strings << "#{dimension_def[:select_expression]} BETWEEN ? AND ?"
            condition_values += values
            filter_texts << "#{dimension_def[:pretty_name]} #{dimension_def[:label_method] ? dimension_def[:label_method].call(values) : "from #{values[0]} to #{values[1]}"}"
          elsif !values[0].blank?
            condition_strings << "#{dimension_def[:select_expression]} >= ?"
            condition_values < values[0]
            filter_texts << "#{dimension_def[:pretty_name]} #{dimension_def[:label_method] ? dimension_def[:label_method].call(values) : "from #{values[0]}"}"
          elsif !values[1].blank?
              condition_strings << "#{dimension_def[:select_expression]} <= ?"
              condition_values < values[1]
              filter_texts << "#{dimension_def[:pretty_name]} #{dimension_def[:label_method] ? dimension_def[:label_method].call(values) : "to #{values[1]}"}"
          end
          includes << dimension_def[:includes] if dimension_def[:includes]
        else
          condition_strings << values.map do |value|
            if dimension_def[:condition_values_method]
              condition_values += dimension_def[:condition_values_method].call(value)
            else
              condition_values << value
            end
            filter_texts << "#{dimension_def[:pretty_name]} #{dimension_def[:label_method] ? dimension_def[:label_method].call(value) : value}"
            includes << dimension_def[:includes] if dimension_def[:includes]
            "(#{dimension_def[:select_expression]}) = ?"
          end.join(' OR ')
        end
      end
      filter_text = filter_texts.join(' and ')
      conditions = [condition_strings.map { |c| "(#{c})" }.join(" AND "), *condition_values]
      includes.uniq!
    else
      filter_text = nil
      conditions = nil
    end
    return conditions, filter_text, includes
  end

  def legal_values_for(field, preserve_filter = false)
    lambda do |search|
      my_filter = search.filter.dup
      my_filter.delete(field.to_s) unless preserve_filter
      conditions, t, includes = make_conditions(my_filter)
      dimension = @dimension_defs[field.to_s]
      if dimension[:includes]
        if dimension[:includes].is_a?(Array)
          includes += dimension[:includes]
        else
          includes << dimension[:includes]
        end
        includes.uniq!
      end
      rows = @target_class.where(@base_condition).find(
          :all,
          :select => "#{dimension[:select_expression]} AS value",
          :conditions => conditions,
          :joins => make_join([], @target_class.name.underscore.to_sym, includes),
          :order => 'value',
          :group => "#{dimension[:select_expression]}"
      )
      if search.filter[field.to_s]
        search.filter[field.to_s].each do |selected_value|
          unless rows.find { |r| r[:value] == selected_value }
            rows << {:value => selected_value}
          end
        end
        rows.sort_by { |r| r[:value] }
      end
      values = rows.map { |r| [dimension[:label_method] && dimension[:label_method].call(r[:value]) || r[:value], r[:value]] }
      values
    end
  end

  def dimension(name, select_expression, options = {})
    includes = options.delete(:includes)
    interval = options.delete(:interval)
    label_method = options.delete(:label_method)
    legal_values = options.delete(:legal_values) || legal_values_for(name)

    raise "Unknown options: #{options.keys.inspect}" unless options.empty?

    @dimension_defs[name.to_s] = {
        :select_expression => select_expression,
        :pretty_name => t(name),
        :url_param_name => name.to_s,
        :legal_values => legal_values,
        :label_method => label_method,
        :includes => includes,
        :interval => interval,
    }
  end

  def get_transactions(tree)
    return tree[:transactions] if tree[:transactions]
    tree[:rows].map { |r| get_transactions(r) }.flatten
  end

  def make_join(joins, model, include, model_class = model.to_s.camelize.constantize)
    case include
    when Array
      include.map { |i| make_join(joins, model, i) }.join(' ')
    when Hash
      sql = ''
      include.each do |parent, child|
        sql << make_join(joins, model, parent) + ' '
        ass = model.to_s.camelize.constantize.reflect_on_association parent
        sql << make_join(joins, parent, child, ass.class_name.constantize)
      end
      sql
    when Symbol
      return '' if joins.include?(include)
      joins << include
      ass = model_class.reflect_on_association include
      raise "Unknown association: #{model} => #{include}" unless ass
      model_table = model.to_s.pluralize
      include_table = ass.table_name
      include_alias = include.to_s.pluralize
      case ass.macro
      when :belongs_to
        "LEFT JOIN #{include_table} #{include_alias} ON #{include_alias}.id = #{model_table}.#{include}_id"
      when :has_one
        fk_col = ass.options[:foreign_key] || "#{model}_id"
        sql = "LEFT JOIN #{include_table} #{include_alias} ON #{include_alias}.#{fk_col} = #{model_table}.id"
        sql << " AND #{include_alias}.deleted_at IS NULL" if ass.klass.paranoid?
        if ass_order = ass.options[:order].try(:to_s)
          ass_order.sub!(/ DESC\s*$/i, '')
          ass_order_prefixed = ass_order.dup
          ActiveRecord::Base.connection.columns(include_table).map(&:name).each do |cname|
            ass_order_prefixed.gsub!(/\b#{cname}\b/, "#{include_alias}.#{cname}")
          end
          sql << " AND  #{ass_order_prefixed} = (SELECT MIN(#{ass_order}) FROM #{include_table} t2 WHERE t2.#{fk_col} = #{model_table}.id #{'AND t2.deleted_at IS NULL' if ass.klass.paranoid?})"
        end
        sql
      else
        raise "Unknown association type: #{ass.macro}"
      end
    when nil
      ''
    else
      raise "Unknown join class: #{include.inspect}"
    end
  end

end
