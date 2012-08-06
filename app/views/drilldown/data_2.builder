xml.chart :xAxisName=> (@dimensions[0][:pretty_name] || 'Transactions').gsub("'", ""), :palette=>"2", 
    :caption => caption, :subcaption=> subcaption,
    :showNames => "1", :showValues => (@result[:rows].size > 15 || @result[:rows][0] && @result[:rows][0][:rows].size > 4) ? 0 : 1, :decimals => "0",
    :numberPrefix => "", :clustered => "0", :exeTime=>"1.5", :showPlotBorder=>"0", :zGapPlot=>"30",
    :zDepth=>"90", :divLineEffect=>"emboss", :startAngX=>"10", :endAngX=>"18", :startAngY=>"-10",
    :numberSuffix => "", :zAxisName=>'Z Axis', :yAxisName => "Transaction #{t(@search.select_value.downcase)}", :endAngY=>"-40" do
  unless @result[:rows].empty?
    xml.categories do
      @result[:rows].each do |result|
        xml.category :label => @dimensions[0][:label_method] ? @dimensions[0][:label_method].call(result[:value]) : result[:value]
      end
    end
    
    @result[:rows][0][:rows].reverse.each_with_index do |result, i|
      xml.dataset :seriesName => @dimensions[1][:label_method] ? @dimensions[1][:label_method].call(result[:value]) : result[:value] do
        for res in @result[:rows]
          value = res[:rows].reverse[i][:value]
          xml.set(:label => @dimensions[0][:label_method] ? @dimensions[0][:label_method].call(res[:value]) : "#{res[:value]}, #{value}",
            :value => res[:rows].reverse[i][@search.select_value == DrilldownSearch::SelectValue::VOLUME ? :volume : :count],
            :link => CGI::escape(url_for(@search.drill_down(@dimensions, res[:value], value).url_options))
          )
        end
      end
    end
    
    xml.styles do
      xml.definition do
        xml.style :name=>"captionFont", :type=>"font", :size=>"15"
      end
      
      xml.application do
        xml.apply :toObject=>"caption", :styles=>"captionfont"
      end
    end
  end
end
