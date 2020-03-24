# frozen_string_literal: true

xml.Row do
  padding_cells = @dimensions.empty? ? 1 : @dimensions.size
  1.upto(padding_cells - 1) { xml.Cell('ss:StyleID' => 'Outer') }

  @search.fields.each_with_index do |field, i|
    xml.Cell('ss:Index' => (padding_cells + i).to_s) { xml.Data t(field), 'ss:Type' => 'String' }
  end
end
