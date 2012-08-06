xml.Row do
  padding_cells = @dimensions.size == 0 ? 1 : @dimensions.size
  1.upto(padding_cells - 1) { |n| xml.Cell('ss:StyleID'=>"Outer")}

  @search.fields.each_with_index do |field, i|
    xml.Cell('ss:Index' => "#{padding_cells + i}") {xml.Data t(field), 'ss:Type' => "String"}
  end
end
