 xml << render(:partial => '/drilldown/excel_row_header')

 result[:transactions].each do |t|
   xml << render(:partial => '/drilldown/excel_row', :locals => {:transaction => t, :previous_transaction => nil, :errors => [], :error_row => false, :meter1_errors => false, :volume_errors => false})
 end
