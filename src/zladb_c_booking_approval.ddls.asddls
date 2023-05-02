@EndUserText.label: 'Booking approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity zladb_c_booking_approval
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
      _Travel            : redirected to parent zladb_c_travel_approval,
      _Carrier,
      _Connection,
      _Customer
}
