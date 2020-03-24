# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.instruct! 'mso-application', progid: 'Excel.Sheet'

xml.Workbook(
  'xmlns' => 'urn:schemas-microsoft-com:office:spreadsheet',
  'xmlns:o' => 'urn:schemas-microsoft-com:office:office',
  'xmlns:x' => 'urn:schemas-microsoft-com:office:excel',
  'xmlns:ss' => 'urn:schemas-microsoft-com:office:spreadsheet',
  'xmlns:html' => 'http://www.w3.org/TR/REC-html40'
) do
  xml << render(partial: '/layouts/excel_styles')

  xml.Worksheet 'ss:Name' => 'Transactions' do
    xml.Table do
      xml.Row 'ss:Height' => '18.75' do
        xml.Cell 'ss:MergeAcross' => '35', 'ss:StyleID' => 'MainTitle' do
          xml.Data caption, 'ss:Type' => 'String'
        end
      end
      xml.Row 'ss:Height' => '15.75' do
        xml.Cell 'ss:MergeAcross' => '35', 'ss:StyleID' => 'SubTitle' do
          xml.Data subcaption, 'ss:Type' => 'String'
        end
      end

      xml.Row 'ss:StyleID' => 'Heading' do
        @transaction_fields.each do |field|
          if field == 'time'
            xml.Cell do
              xml.Data (l :short_date).to_s, 'ss:Type' => 'String'
            end
            xml.Cell do
              xml.Data (l :time).to_s, 'ss:Type' => 'String'
            end
          else
            xml.Cell do
              xml.Data (l field).to_s, 'ss:Type' => 'String'
            end
          end
        end
      end

      volume_total = 0
      volume_compensated_total = 0
      @transactions.each do |transaction|
        if transaction.operation == Transaction::Operation::FUELLING
          volume_total += transaction.volume
          volume_compensated_total += transaction.volume_compensated
        else
          volume_total -= transaction.volume
          volume_compensated_total -= transaction.volume_compensated
        end
        xml.Row do
          @transaction_fields.each do |field|
            field_map = @transaction_fields_map[field.to_sym]
            if field == 'time'
              xml.Cell 'ss:StyleID' => 'DateOnlyFormat' do
                xml.Data transaction.completed_at.gmtime.xmlschema, 'ss:Type' => 'DateTime'
              end
              xml.Cell 'ss:StyleID' => 'TimeOnlyFormat' do
                xml.Data transaction.completed_at.gmtime.xmlschema, 'ss:Type' => 'DateTime'
              end
            else
              value = field_map[:attr_method] ? field_map[:attr_method].call(transaction) : transaction.send(field)
              xml.Cell field_map[:excel_style] ? { 'ss:StyleID' => field_map[:excel_style] } : {} do
                xml.Data value, 'ss:Type' => field_map[:excel_type] || 'String'
              end
            end
          end
        end
      end
      xml.Row do
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell do
          xml.Data '', 'ss:Type' => 'String'
        end
        xml.Cell 'ss:styleID' => 'StandardNumberFormat' do
          xml.Data volume_total.to_s, 'ss:Type' => 'Number'
        end
        xml.Cell 'ss:styleID' => 'StandardNumberFormat' do
          xml.Data volume_compensated_total.to_s, 'ss:Type' => 'Number'
        end
      end
    end
  end
end
