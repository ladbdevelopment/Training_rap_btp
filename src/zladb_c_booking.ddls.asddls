@EndUserText.label: 'Booking'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity zladb_c_booking
  as projection on zladb_i_booking
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      @ObjectModel.text.element: ['CarrierName']
      CarrierId,
      _Carrier.name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _Travel : redirected to parent zladb_c_travel,
      _BookingSupplement : redirected to composition child zladb_C_booksuppl,
      _Carrier,
      _Connection,
      _Customer
      
}
