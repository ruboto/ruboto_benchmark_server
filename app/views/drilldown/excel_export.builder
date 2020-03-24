xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.instruct! 'mso-application', :progid => "Excel.Sheet"

xml.Workbook(
  'xmlns' => "urn:schemas-microsoft-com:office:spreadsheet",
  'xmlns:o' => "urn:schemas-microsoft-com:office:office",
  'xmlns:x' => "urn:schemas-microsoft-com:office:excel",
  'xmlns:ss' => "urn:schemas-microsoft-com:office:spreadsheet",
  'xmlns:html' => "http://www.w3.org/TR/REC-html40"
) do
  xml << render(:partial => '/layouts/excel_styles')

  xml.Worksheet 'ss:Name' => "Transaction Summary" do
    xml.Table do
      xml.Row 'ss:Height' => "18.75" do
        xml.Cell 'ss:MergeAcross' => @search.list ? @search.fields.size - 1 : @dimensions.size + 2, 'ss:StyleID' => "MainTitle" do
          xml.Data caption, 'ss:Type' => "String"
        end
      end
      xml.Row 'ss:Height' => "15.75" do
        xml.Cell 'ss:MergeAcross' => @search.list ? @search.fields.size - 1 : @dimensions.size + 2, 'ss:StyleID' => "SubTitle" do
          xml.Data subcaption, 'ss:Type' => "String"
        end
      end

      xml.Row do
        @dimensions.each do |d|
          xml.Cell 'ss:StyleID' => "Heading" do
            xml.Data "#{h d[:pretty_name]}", 'ss:Type' => "String"
          end
        end
        xml.Cell 'ss:StyleID' => "Heading" do
          xml.Data "#{l :count}", 'ss:Type' => "String"
        end
        xml.Cell 'ss:StyleID' => "Heading" do
          xml.Data "#{l :volume}", 'ss:Type' => "String"
        end
        xml.Cell 'ss:StyleID' => "Heading" do
          xml.Data "#{l :volume_compensated}", 'ss:Type' => "String"
        end
      end

      xml << excel_summary_row(@result)
    end
  end
end
