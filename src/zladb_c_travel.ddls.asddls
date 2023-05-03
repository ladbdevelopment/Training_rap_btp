@EndUserText.label: 'Travel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity zladb_c_travel
  provider contract transactional_query // Indicarle el contrato de la query transaccional
  as projection on zladb_i_travel
{
  key TravelId,
      @ObjectModel.text.element: ['AgencyName']
      AgencyId,
      _Agency.Name as AgencyName,
      @ObjectModel.text.element: ['CustomerName']
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      Createdby,
      Createdat,
      Lastchangedby,
      Lastchangedat,
      
      // Publicar una columna calculada o columna virtual
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @EndUserText.label: 'Discount'
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_LADB_VIRT_ELEM'
      // SADL - Service Adaptation Description Model
      virtual DiscountPrice : /dmo/total_price,
      
      /* Associations */
      _Agency,
      _Booking : redirected to composition child zladb_c_booking,
      _Currency,
      _Customer
}
