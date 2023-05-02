@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Travel'
define root view entity zladb_i_travel
  as select from zladb_travel
  composition [0..*] of zladb_i_booking as _Booking
  // Realizo la asociación para poder tener el acceso a las ayudas de busquedas
  // para identificar el cliente, puedo vincular en los campos para tener acceso a
  // a las entidades finales
  association [0..1] to /DMO/I_Agency   as _Agency   on $projection.AgencyId = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
  association [0..1] to I_Currency      as _Currency on $projection.CurrencyCode = _Currency.Currency
{
  key travel_id      as TravelId,
      agency_id      as AgencyId,
      customer_id    as CustomerId,
      begin_date     as BeginDate,
      end_date       as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee    as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price    as TotalPrice,
      currency_code  as CurrencyCode,
      description    as Description,
      overall_status as OverallStatus,

      // Campos de tipo auditoría
      @Semantics.user.createdBy: true
      createdby      as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat      as Createdat,
      @Semantics.user.lastChangedBy: true
      lastchangedby  as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat  as Lastchangedat,
      // Asociaciones
      _Booking,
      _Agency,
      _Customer,
      _Currency
}
