# frozen_string_literal: true

xml.chart(xAxisName: (@dimensions[0][:pretty_name] || 'Transactions').delete("'"),
          showValues: '1', caption: caption, subcaption: subcaption,
          yAxisName: "Transaction #{t(@search.select_value.downcase)}", numberSuffix: '') do
  @result[:rows].each do |res|
    xml.set(name: @dimensions[0][:label_method] ? @dimensions[0][:label_method].call(res[:value]) : res[:value],
            value: res[@search.select_value == DrilldownSearch::SelectValue::VOLUME ? :volume : :count],
            link: if @dimensions[0][:url_param_name]
                    CGI.escape(url_for(@search.drill_down(@dimensions, res[:value]).url_options))
                  else
                    ''
                  end)
  end
end
