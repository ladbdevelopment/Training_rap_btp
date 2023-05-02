@EndUserText.label: 'Travel approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity zladb_c_travel_approval
  provider contract transactional_query
  as projection on zladb_i_travel
{
  key TravelId,
      @ObjectModel.text.element: ['AgencyName']
      AgencyId,
      _Agency.Name       as AgencyName,
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

      /* Associations */
      _Agency,
      _Booking : redirected to composition child zladb_c_booking_approval,
      _Currency,
      _Customer
}
