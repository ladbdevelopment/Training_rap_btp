@EndUserText.label: 'Booking supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity zladb_C_booksuppl
  as projection on zladb_i_booksuppl
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: ['SupplementDescription']
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized, // Se usa el localized para que tome por defecto el idioma del usuario
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Travel  : redirected to zladb_c_travel,      
      _Booking : redirected to parent zladb_c_booking,
      _Supplement,
      _SupplementText
      
}
