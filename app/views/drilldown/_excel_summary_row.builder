# frozen_string_literal: true

xml.Row do
  1.upto(dimension - headers.size - 1) { xml.Cell('ss:StyleID' => 'Outer') }

  headers.each_with_index do |h, i|
    xml.Cell('ss:StyleID' => 'Outer', 'ss:Index' => (dimension - headers.size + i).to_s) do
      xml.Data value_label(@dimensions.size - headers.size + i - 1, h[:value]), 'ss:Type' => 'String'
    end
  end
  xml.Cell('ss:StyleID' => 'Outer', 'ss:Index' => dimension.to_s) { xml.Data value_label(dimension - 1, result[:value]), 'ss:Type' => 'String' } if dimension.positive?

  xml.Cell('ss:StyleID' => 'Outer') { xml.Data result[:count].inspect, 'ss:Type' => 'Number' }
  xml.Cell('ss:StyleID' => 'Outer') { xml.Data result[:volume].inspect, 'ss:Type' => 'Number' }
  xml.Cell('ss:StyleID' => 'Outer') { xml.Data result[:volume_compensated].inspect, 'ss:Type' => 'Number' }
end
