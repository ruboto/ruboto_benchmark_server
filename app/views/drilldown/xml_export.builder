payment_map = {
  PaymentType::CASH => 'CA',
  PaymentType::CONTRACT => 'CO',
  PaymentType::AUTHORIZATION => 'CO',
  PaymentType::CARNET => 'CN'
}

operation_map = {
  Transaction::Operation::FUELLING => 'FU',
  Transaction::Operation::DEFUELLING => 'DE',
  Transaction::Operation::CREDIT => 'CR'
}

direction_map = {
  Transaction::Operation::DEFUELLING => 'FR',
  Transaction::Operation::FUELLING => 'TO',
  Transaction::Operation::CREDIT => 'TO'
}

supplier_code_map = {
  'Shell' => 'SHL',
  'Esso' => 'XOM',
  'SAS Oil' => 'SAO',
  'Statoil' => 'STA',
  'Total' => 'TOT',
}

xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8", :standalone => "yes"

xml.FuelTransactionTransmission do
  xml.FuelTransactionTransmissionHeader do
    #FIXME (lars): unique id
    xml.FuelTransactionTransmissionId('bvuNcc66Kr3B36abIlXvtB')
    xml.FuelTransactionCreationDate(Time.now.strftime('%Y-%m-%dT%H:%M:%S'))
    xml.FuelTransactionVersion('3.0.0')
  end

  @transactions.each do |t|
    ticket_type = 'O'
    if t.credit?
      # Do not use root transaction if supplier changes!
      # t = t.root_transaction
      ticket_type = 'C'
    end

    if t.copy_no > 0 && !t.credit?
      ticket_type = 'R'
    end

    xml.FuelTransaction do
      xml.IPTransaction do
        xml.Header do
          xml.IntoPlaneCode('GFS')
          xml.IntoPlaneName('GM Fueling Services')
          xml.AirportCode('OSL')
          xml.TicketNumber(t.root_transaction.xml_receipt_code, :TicketType => ticket_type, :TicketSource => (t.adjusted? ? 'M' : 'E'),
            :TicketStatus => 'F')
          xml.PreviousTicketNumber(t.root_transaction.xml_receipt_code, :PreviousITPDate => t.root_transaction.created_at.strftime('%Y-%m-%dT%H:%M:%S') ) if ticket_type == 'R'
          xml.TransactionDate(t.created_at.strftime('%Y-%m-%dT%H:%M:%S'))
        end

        xml.FlightInformation do
          xml.AirlineFlightID(t.flight_no.upcase)
          xml.AircraftIdentification(t.aircraft_registration || 'ANY')
          xml.InternationalFlight(t.external_flight)
          xml.TicketReferenceValue(t.destination, :TicketReferenceValueType => "NDT")
          xml.TicketReferenceValue(t.aircraft_subtype_code || 'ANY', :TicketReferenceValueType => "AC")
          xml.TicketReferenceValue(t.authorization.authorization_reference, :TicketReferenceValueType => "PO") if t.authorization_id
        end

        xml.PaymentInformation do
          xml.PaymentType(payment_map[t.payment_type])
          if t.carnet?
            xml.CardInformation do
              xml.CardName(t.customer_name)
              xml.CardNumber(t.carnet_no)
              m,y=t.carnet_expiry.split('/')
              exp_date = Time.local(y, m)
              exp_date += 1.month
              exp_date -= 1.day
              xml.CardExpiry(exp_date.strftime('%Y-%m-%dT%H:%M:%S'))
            end #CardInformation
          end #PaymentType
          xml.AmountReceived(t.cash_price, :Currency => 'NOK') if t.cash?
        end #PaymentInformation

        xml.IPTLine do
          xml.IPTransactionType do
            xml.IPTransactionCode(operation_map[t.operation])
          end

          xml.TransactionParties do
            xml.Sale do
              rec_code = '999' if t.carnet?
              rec_code ||= t.customer_iata_code.try(:upcase)
              rec_code  = '999' unless IataCodes::IATA_CODES.include?(rec_code)
              xml.ReceiverCode(rec_code)
              xml.ReceiverName((t.carnet? && t.contract) ? t.contract.customer.name : t.customer_name)

              customer_no = t.contract.supplier_customer_no if (t.contract && t.contract.supplier.name == 'Esso')
              customer_no ||= t.invoice_code.try(:upcase)
              customer_no ||= t.carnet_no if t.carnet?
              #customer_no ||= t.authorization.authorization_reference if t.authorization_id
              customer_no ||= t.customer_iata_code.try(:upcase)

              xml.ReceiverAccountNumber(customer_no || '999') # FIXME(IATA): add 999 for unknown
              xml.SupplierOROwnerCode(supplier_code_map[t.supplier.name])
              xml.SupplierOROwnerName(t.supplier.name)
            end
          end #TransactionParties

          xml.MovementInformation(:Direction => direction_map[t.operation]) do
            xml.ProductInformation do
              xml.ProductID('JETA1', :ProductIDQualifier => "PRDT")
              xml.ProductDescription('JET A-1')
              if t.cash?
                xml.Charges do
                  xml.Remark() # FIXME(IATA): mandatory in XSD not in doc
                  xml.UnitRate(t.supplier_price)
                  xml.CurrencyCode('NOK')
                  xml.UnitRateType('UR')
                  xml.UOM('LT')
                end
              end

              if t.co2_fee?
                xml.LocalTax(:LocalTaxType => 'CO2') do
                  xml.LocalTaxDescription('CO2 tax')
                  xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                  xml.LocalTaxRateType('UR')
                  xml.LocalTaxPricingCurrencyCode('NOK')
                  xml.LocalTaxPricingUOM('LT')
                  xml.LocalTaxPricingRate(t.co2_fee)
                  xml.LocalTaxPricingAmount(t.co2_fee_price)
                  xml.LocalTaxTicketCurrencyCode('NOK')
                  xml.LocalTaxTicketUOM('LT')
                  xml.LocalTaxTicketUnitRate(t.co2_fee)
                  xml.LocalTaxTicketAmount(t.co2_fee_price)

                  xml.SubTax(:SubTaxType => 'VAT') do
                    amount = t.cash? ? (t.co2_fee_price * t.vat_factor).round(2) : 0
                    xml.SubTaxDescription('VAT')
                    xml.SubTaxJurisdictionTaxBasis('GR')
                    xml.SubTaxRateType('P')
                    xml.SubTaxPricingCurrencyCode('NOK')

                    # FIXME (IATA): mandatory in XSD, optional in doc
                    xml.SubTaxCurrencyConversion do
                      xml.ConversionMechanism('M')
                      xml.CurrencyFrom('NOK', :FactorFrom => '1')
                      xml.CurrencyTo('NOK', :FactorTo => '1')
                      xml.ExchangeRate('1.0')
                    end

                    xml.SubTaxPricingAmount(amount)
                    xml.SubTaxPricingRate(t.vat_factor * 100)
                    xml.SubTaxTicketCurrencyCode('NOK')
                    xml.SubTaxTicketUnitRate(t.vat_factor * 100)
                    xml.SubTaxTicketAmount(amount)
                  end
                end
              end

              if t.vat?
                xml.LocalTax(:LocalTaxType => 'VAT') do
                  amount = t.cash? ? (t.fuel_price * t.vat_factor).round(2) : 0
                  xml.LocalTaxDescription('VAT')
                  xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                  xml.LocalTaxRateType('P')
                  xml.LocalTaxPricingCurrencyCode('NOK')
                  xml.LocalTaxPricingRate(t.vat_factor * 100)
                  xml.LocalTaxPricingAmount(amount)
                  xml.LocalTaxTicketCurrencyCode('NOK')
                  xml.LocalTaxTicketUnitRate(t.vat_factor * 100)
                  xml.LocalTaxTicketAmount(amount)
                end
              end
            end #ProductInformation

            # Non governmental fees
            if t.airfield_fee?
              xml.ProductInformation do
                xml.ProductID('APT', :ProductIDQualifier => "FEE")
                xml.ProductDescription('Airfield fee')
                xml.Charges do
                  xml.Remark() # FIXME(IATA): mandatory in XSD not in doc
                  xml.UnitRate(t.airfield_fee)
                  xml.CurrencyCode('NOK')
                  xml.UnitRateType('UR')
                  xml.UOM('LT')
                end
                if t.vat?
                  xml.LocalTax(:LocalTaxType => 'VAT') do
                    xml.LocalTaxDescription('VAT')
                    xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                    xml.LocalTaxRateType('P')
                    xml.LocalTaxPricingCurrencyCode('NOK')
                    xml.LocalTaxPricingRate(t.vat_factor * 100)
                    amount = (t.airfield_fee_price * t.vat_factor).round(2)
                    xml.LocalTaxPricingAmount(amount)
                    xml.LocalTaxTicketCurrencyCode('NOK')
                    xml.LocalTaxTicketUnitRate(t.vat_factor * 100)
                    xml.LocalTaxTicketAmount(amount)
                  end
                end #VAT
              end #ProductInformation
            end

            if t.receptacle_fee?
              xml.ProductInformation do
                xml.ProductID('CNT', :ProductIDQualifier => "FEE")
                xml.ProductDescription('Receptacle fee')
                xml.Charges do
                  xml.Remark() # FIXME(IATA): mandatory in XSD not in doc
                  xml.UnitRate(t.receptacle_fee)
                  xml.CurrencyCode('NOK')
                  xml.UnitRateType('UR')
                  xml.UOM('LT')
                end
                if t.vat?
                  xml.LocalTax(:LocalTaxType => 'VAT') do
                    xml.LocalTaxDescription('VAT')
                    xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                    xml.LocalTaxRateType('P')
                    xml.LocalTaxPricingCurrencyCode('NOK')
                    xml.LocalTaxPricingRate(t.vat_factor * 100)
                    amount = (t.receptacle_fee_price * t.vat_factor).round(2)
                    xml.LocalTaxPricingAmount(amount)
                    xml.LocalTaxTicketCurrencyCode('NOK')
                    xml.LocalTaxTicketUnitRate(t.vat_factor * 100)
                    xml.LocalTaxTicketAmount(amount)
                  end
                end #VAT
              end #ProductInformation
            end

            if t.defuelling_fee?
              xml.ProductInformation do
                xml.ProductID('DEF', :ProductIDQualifier => "FEE")
                xml.ProductDescription('Defuelling fee')
                xml.Charges do
                  xml.Remark() # FIXME(IATA): mandatory in XSD not in doc
                  xml.UnitRate(t.defuelling_fee)
                  xml.CurrencyCode('NOK')
                  xml.UnitRateType('UR')
                  xml.UOM('LT')
                end
                if t.vat?
                  xml.LocalTax(:LocalTaxType => 'VAT') do
                    xml.LocalTaxDescription('VAT')
                    xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                    xml.LocalTaxRateType('P')
                    xml.LocalTaxPricingCurrencyCode('NOK')
                    xml.LocalTaxPricingRate(t.vat_factor * 100)
                    amount = (t.defuelling_fee_price * t.vat_factor).round(2)
                    xml.LocalTaxPricingAmount(amount)
                    xml.LocalTaxTicketCurrencyCode('NOK')
                    xml.LocalTaxTicketUnitRate(t.vat_factor * 100)
                    xml.LocalTaxTicketAmount(amount)
                  end
                end #VAT
              end #ProductInformation
            end

            if t.zero_fuelling_fee?
              xml.ProductInformation do
                xml.ProductID('NFF', :ProductIDQualifier => "FEE")
                xml.ProductDescription('Zero fuelling fee')
                xml.Charges do
                  xml.Remark() # FIXME(IATA): mandatory in XSD not in doc
                  xml.UnitRate(t.zero_fuelling_fee)
                  xml.CurrencyCode('NOK')
                  xml.UnitRateType('FF')
                  xml.UOM('LT')
                end
                if t.vat?
                  xml.LocalTax(:LocalTaxType => 'VAT') do
                    xml.LocalTaxDescription('VAT')
                    xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                    xml.LocalTaxRateType('P')
                    xml.LocalTaxPricingCurrencyCode('NOK')
                    xml.LocalTaxPricingRate(t.vat_factor * 100)
                    amount = (t.zero_fuelling_fee_price * t.vat_factor).round(2)
                    xml.LocalTaxPricingAmount(amount)
                    xml.LocalTaxTicketCurrencyCode('NOK')
                    xml.LocalTaxTicketUnitRate(t.vat_factor * 100)
                    xml.LocalTaxTicketAmount(amount)
                  end
                end #VAT
              end #ProductInformation
            end

            if t.remote_fuelling_fee?
              xml.ProductInformation do
                xml.ProductID('OFF', :ProductIDQualifier => "FEE")
                xml.ProductDescription('Remote fuelling fee')
                xml.Charges do
                  xml.Remark() # FIXME(IATA): mandatory in XSD not in doc
                  xml.UnitRate(t.remote_fuelling_fee)
                  xml.CurrencyCode('NOK')
                  xml.UnitRateType('FF')
                  xml.UOM('LT')
                end
                if t.vat?
                  xml.LocalTax(:LocalTaxType => 'VAT') do
                    xml.LocalTaxDescription('VAT')
                    xml.LocalTaxLocalJurisdictionTaxBasis('GR')
                    xml.LocalTaxRateType('P')
                    xml.LocalTaxPricingCurrencyCode('NOK')
                    xml.LocalTaxPricingRate(t.vat_factor * 100)
                    amount = (t.remote_fuelling_fee_price * t.vat_factor).round(2)
                    xml.LocalTaxPricingAmount(amount)
                    xml.LocalTaxTicketCurrencyCode('NOK')
                    xml.LocalTaxTicketUnitRate(t.vat_factor * 100)
                    xml.LocalTaxTicketAmount(amount)
                  end
                end #VAT
              end #ProductInformation
            end

            xml.StandNumber(t.stand.code)
            xml.Equipment do
              xml.FuelingEquipmentID(t.vehicle.name)
              xml.FuelingType((t.vehicle.dispenser? ? 'HYD' : 'REF'))
              xml.PITNumber(t.pit.code) if t.pit
              xml.Operator('GFS OP')
              xml.AverageFuelTemperature(t.temperature, :TUOM => 'C')

              xml.DensityInformation(:DensityType => 'MEA') do
                xml.Density(t.density, :DensityUOM => 'KGM')
                xml.Temperature(t.temperature, :TUOM => 'C')
              end

              xml.MeterReading(:MeterID => 'meter1') do
                xml.MeterReadingStart(t.meter1_start_volume)
                xml.MeterReadingEnd(t.meter1_stop_volume)
                xml.MeterQuantityDelivered(t.meter1_volume, :MQDUOM => 'LT')
              end

              if (t.meter2_volume != 0)
                xml.MeterReading(:MeterID => 'meter2') do
                  xml.MeterReadingStart(t.meter2_start_volume)
                  xml.MeterReadingEnd(t.meter2_stop_volume)
                  xml.MeterQuantityDelivered(t.meter2_volume, :MQDUOM => 'LT')
                end
              end
            end #Equipment


            xml.TotalQuantity(t.volume, :TQDFlag => 'GR', :TQDUOM => 'LT')

            xml.TransactionTime do
              xml.LocalDateTimeStart(t.started_at.localtime.strftime('%Y-%m-%dT%H:%M:00'))
              xml.LocalDateTimeFinished(t.completed_at.localtime.strftime('%Y-%m-%dT%H:%M:00'))
              xml.GMTDateTimeStart(t.started_at.gmtime.strftime('%Y-%m-%dT%H:%M:00'))
              xml.GMTDateTimeFinished(t.completed_at.gmtime.strftime('%Y-%m-%dT%H:%M:00'))
            end
          end #MovementInformation
        end # IPTLine

        xml.Summary do
          xml.FuelTransactionLineCount('1')
          xml.TotalFuelQuantity(t.volume)
        end

      end #IPTransaction
    end #FuelTransaction
  end

  xml.FuelTransactionTransmissionSummary do
    xml.FuelTransactionMessageCount(@transactions.size)
    xml.FuelTransactionTotalFuelQuantity(@transactions.inject(0){|total, transaction| total + transaction.volume})
  end
end
