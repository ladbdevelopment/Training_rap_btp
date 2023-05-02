@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zladb_i_booking
  as select from zladb_booking
  composition [0..*] of zladb_i_booksuppl as _BookingSupplement
  association        to parent zladb_i_travel    as _Travel on $projection.TravelId     = _Travel.TravelId
  association [1..1] to /DMO/I_Customer   as _Customer      on $projection.CustomerId   = _Customer.CustomerID
  association [1..1] to /dmo/carrier      as _Carrier       on $projection.CarrierId    = _Carrier.carrier_id
  association [1..1] to /DMO/I_Connection as _Connection    on $projection.CarrierId    = _Connection.AirlineID
                                                           and $projection.ConnectionId = _Connection.ConnectionID

{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection
}
