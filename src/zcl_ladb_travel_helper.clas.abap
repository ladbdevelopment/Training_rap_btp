CLASS zcl_ladb_travel_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id TYPE tt_travel_id.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_ladb_travel_helper IMPLEMENTATION.

  METHOD calculate_price.

    DATA: total_book_price_by_trav_curr  TYPE /dmo/total_price,
          total_suppl_price_by_trav_curr TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zladb_i_travel
         ENTITY Travel
         FROM VALUE #( FOR <lv_travel_id> IN it_travel_id (
                                TravelId = <lv_travel_id>
                                %control-CurrencyCode = if_abap_behv=>mk-on ) )
         RESULT  DATA(lt_read_travel).

    READ ENTITIES OF zladb_i_travel
         ENTITY Travel BY \_Booking
         FROM VALUE #( FOR <lv_travel_id> IN it_travel_id (
                        TravelId = <lv_travel_id>
                        %control-FlightPrice   = if_abap_behv=>mk-on
                        %control-BookingStatus = if_abap_behv=>mk-on
                        %control-CurrencyCode  = if_abap_behv=>mk-on ) )
         RESULT DATA(lt_read_booking_by_travel).

    LOOP AT lt_read_booking_by_travel
         INTO DATA(ls_booking)
         GROUP BY ls_booking-TravelId
         INTO DATA(ls_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = ls_travel_key ]
            TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP ls_travel_key INTO DATA(ls_booking_result)
        GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_curr).

        total_book_price_by_trav_curr = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_booking_line).
          total_book_price_by_trav_curr   += ls_booking_line-FlightPrice.
        ENDLOOP.

        IF lv_curr  = <ls_travel>-CurrencyCode.
          <ls_travel>-TotalPrice += total_book_price_by_trav_curr.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = total_book_price_by_trav_curr
              iv_currency_code_source = lv_curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(total_book_price_per_curr) ).
          <ls_travel>-TotalPrice += total_book_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    READ ENTITIES OF zladb_i_travel
             ENTITY Booking BY \_BookingSupplement
                   FROM VALUE #( FOR ls_travel IN lt_read_booking_by_travel (
                          TravelId              = ls_travel-TravelId
                          BookingId             = ls_travel-BookingId
                          %control-Price        = if_abap_behv=>mk-on
                          %control-CurrencyCode = if_abap_behv=>mk-on ) )
          RESULT  DATA(lt_read_booksuppl).

    LOOP AT lt_read_booksuppl INTO DATA(ls_booking_suppl)
      GROUP BY ls_booking_suppl-TravelId INTO ls_travel_key.

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = ls_travel_key ] TO <ls_travel>.

      LOOP AT GROUP ls_travel_key INTO DATA(ls_bookingsuppl_result)
        GROUP BY ls_bookingsuppl_result-CurrencyCode INTO lv_curr.

        total_suppl_price_by_trav_curr = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_booking_suppl2).
          total_suppl_price_by_trav_curr    += ls_booking_suppl2-price.
        ENDLOOP.

        IF lv_curr  = <ls_travel>-CurrencyCode.
          <ls_travel>-TotalPrice    += total_suppl_price_by_trav_curr.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency( EXPORTING iv_amount               = total_suppl_price_by_trav_curr
                                                           iv_currency_code_source = lv_curr
                                                           iv_currency_code_target = <ls_travel>-CurrencyCode
                                                           iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
                                                 IMPORTING ev_amount               = DATA(total_suppl_price_per_curr) ).
          <ls_travel>-TotalPrice     += total_suppl_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zladb_i_travel
           ENTITY Travel
           UPDATE
           FIELDS ( TotalPrice )
           WITH VALUE #( FOR travel IN lt_read_travel (
                            TravelId            = travel-TravelId
                            TotalPrice          = travel-TotalPrice
                            %control-TotalPrice = if_abap_behv=>mk-on ) )
           FAILED DATA(lt_failed)
           REPORTED DATA(lt_reported).

  ENDMETHOD.
ENDCLASS.

