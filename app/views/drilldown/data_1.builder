xml.chart(:xAxisName=> (@dimensions[0][:pretty_name] || 'Transactions').gsub("'", ""), 
    :showValues => '1', :caption=> caption, :subcaption=> subcaption, 
    :yAxisName => "Transaction #{t(@search.select_value.downcase)}", :numberSuffix => "") do
  for res in @result[:rows]
    xml.set(:name => @dimensions[0][:label_method] ? @dimensions[0][:label_method].call(res[:value]) : res[:value],
        :value => res[@search.select_value == DrilldownSearch::SelectValue::VOLUME ? :volume : :count],
        :link => @dimensions[0][:url_param_name] ? CGI::escape(url_for(@search.drill_down(@dimensions, res[:value]).url_options)) : '')
  end
end
