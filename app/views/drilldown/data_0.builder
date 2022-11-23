# frozen_string_literal: true

xml.chart(xAxisName: 'Transactions',
          showValues: '1', caption:, subcaption:,
          yAxisName: "Transaction #{t(@search.select_value.downcase)}", numberSuffix: '') do
  xml.set(
    name: @result[:value0],
    value: @result[@search.select_value == DrilldownSearch::SelectValue::VOLUME ? :volume : :count]
  )
end
