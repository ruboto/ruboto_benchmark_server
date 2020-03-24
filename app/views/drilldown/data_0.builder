xml.chart(:xAxisName => 'Transactions',
          :showValues => '1', :caption => caption, :subcaption => subcaption,
          :yAxisName => "Transaction #{t(@search.select_value.downcase)}", :numberSuffix => "") do
  filter = @search.filter.dup || {}
  xml.set(
    :name => @result[:value0],
    :value => @result[@search.select_value == DrilldownSearch::SelectValue::VOLUME ? :volume : :count]
  )
end
