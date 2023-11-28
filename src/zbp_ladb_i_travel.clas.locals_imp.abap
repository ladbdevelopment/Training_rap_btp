CLASS lhc_zladb_i_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zladb_i_travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zladb_i_travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION zladb_i_travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION zladb_i_travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION zladb_i_travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zladb_i_travel~validateCustomer.

    METHODS validateDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zladb_i_travel~validateDate.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zladb_i_travel~validateStatus.

ENDCLASS.

CLASS lhc_zladb_i_travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zladb_i_travel
        IN LOCAL MODE
        ENTITY Travel
        FIELDS ( TravelId
                 OverallStatus )
         WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
         RESULT DATA(lt_entity_travel).


    result = VALUE #( FOR <ls_travel> IN lt_entity_travel (
                             %key     = <ls_travel>-TravelId
                             %field-TravelId  = if_abap_behv=>fc-f-read_only
                             %field-OverallStatus  = if_abap_behv=>fc-f-read_only
                             %action-acceptTravel = COND #( WHEN <ls_travel>-OverallStatus = 'A'
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled )
                             %action-rejectTravel = COND #( WHEN <ls_travel>-OverallStatus = 'X'
                                                              THEN if_abap_behv=>fc-o-disabled
                                                              ELSE if_abap_behv=>fc-o-enabled )
                             ) ).
  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980015551'
                              THEN if_abap_behv=>auth-allowed
                              ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = VALUE #( %key = <ls_keys>-%key
                             %op-%update                    = lv_auth
                             %delete                        = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %action-acceptTravel           = lv_auth
                             %action-rejectTravel           = lv_auth
                             %assoc-_Booking                = lv_auth ).
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zladb_i_travel
     IN LOCAL MODE ENTITY Travel
     UPDATE
     FIELDS ( OverallStatus )
     WITH  VALUE #( FOR <key> IN keys ( TravelId = <key>-TravelId
                                         OverallStatus = 'A' ) )
     FAILED failed
     REPORTED reported.

    CHECK failed IS INITIAL.

    READ ENTITIES OF zladb_i_travel
         IN LOCAL MODE
         ENTITY Travel
         FIELDS ( AgencyId
                  CustomerId
                  BeginDate
                  EndDate
                  BookingFee
                  TotalPrice
                  CurrencyCode
                  Description
                  OverallStatus
                  CreatedBy
                  CreatedAt
                  LastChangedBy
                  LastChangedAt )
          WITH VALUE #( FOR <row_key> IN keys ( TravelId = <row_key>-TravelId ) )
          RESULT DATA(lt_entity_travel)
          FAILED failed.

    result = VALUE #( FOR <fs_travel> IN lt_entity_travel ( TravelId = <fs_travel>-TravelId
                                                            %param   = <fs_travel> ) ).


    LOOP AT lt_entity_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      APPEND VALUE #( TravelId = <ls_travel>-TravelId
                      %msg = new_message( id                      = 'ZLADB_MSG'
                                          number                  = '001'
                                          v1                      = shift_left( val = <ls_travel>-TravelId sub = '0' )
                                          severity                = if_abap_behv_message=>severity-success )
                      %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD createTravelByTemplate.

*  keys[ 1 ]-
*  result[ 1 ]-
*  mapped-
*  failed-
*  reported-

* EML --> Entity Manipulation Language

    READ ENTITIES OF zladb_i_travel "RAP BO = CDS + Behavior
         IN LOCAL MODE
         ENTITY Travel
         FIELDS ( TravelId         "ALL FIELDS
                  AgencyId
                  CustomerId
                  BookingFee
                  TotalPrice
                  CurrencyCode )
          WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
          RESULT DATA(lt_entity_travel) "Table contains all data
*          failed data(failed_data)
          FAILED failed  "implicit param - if any failed - get data
*          reported data(reported_data)
          REPORTED reported. "if message are raised in BO implementation

    CHECK failed IS INITIAL.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    DATA lt_create TYPE TABLE FOR CREATE zladb_i_travel\\Travel.

    SELECT MAX( travel_id ) FROM zladb_travel INTO @DATA(lv_travel_id).

    lt_create = VALUE #( FOR <row> IN lt_entity_travel INDEX INTO idx
                            ( TravelId      = lv_travel_id + idx
                              AgencyId      = <row>-AgencyId
                              CustomerId    = <row>-CustomerId
                              BeginDate     = lv_today
                              EndDate       = lv_today + 30
                              BookingFee    = <row>-BookingFee
                              TotalPrice    = <row>-TotalPrice
                              CurrencyCode  = <row>-CurrencyCode
                              description    = 'Comments here'
                              OverallStatus = 'O' ) ).

    MODIFY ENTITIES OF zladb_i_travel
        IN LOCAL MODE ENTITY Travel
        CREATE
        FIELDS ( TravelId
                 AgencyId
                 CustomerId
                 BeginDate
                 EndDate
                 BookingFee
                 TotalPrice
                 CurrencyCode
                 Description
                 OverallStatus )
         WITH lt_create
         MAPPED mapped
         FAILED failed
         REPORTED reported.

    result = VALUE #( FOR <row_create> IN lt_create INDEX INTO idx
                        ( %cid_ref = keys[ idx ]-%cid_ref
                          %key     = keys[ idx ]-TravelId
                          %param   = CORRESPONDING #( <row_create> ) ) ).


  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zladb_i_travel
     IN LOCAL MODE ENTITY Travel
     UPDATE
     FIELDS ( OverallStatus )
     WITH  VALUE #( FOR <key> IN keys ( TravelId = <key>-TravelId
                                         OverallStatus = 'X' ) )
     FAILED failed
     REPORTED reported.

    CHECK failed IS INITIAL.

    READ ENTITIES OF zladb_i_travel
         IN LOCAL MODE
         ENTITY Travel
         FIELDS ( AgencyId
                  CustomerId
                  BeginDate
                  EndDate
                  BookingFee
                  TotalPrice
                  CurrencyCode
                  Description
                  OverallStatus
                  CreatedBy
                  CreatedAt
                  LastChangedBy
                  LastChangedAt )
          WITH VALUE #( FOR <row_key> IN keys ( TravelId = <row_key>-TravelId ) )
          RESULT DATA(lt_entity_travel)
          FAILED failed.

    result = VALUE #( FOR <fs_travel> IN lt_entity_travel ( TravelId = <fs_travel>-TravelId
                                                            %param   = <fs_travel> ) ).

    LOOP AT lt_entity_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      APPEND VALUE #( TravelId = <ls_travel>-TravelId
                      %msg = new_message( id                      = 'ZCOL_MSG'
                                          number                  = '002'
                                          v1                      = shift_left( val = <ls_travel>-TravelId sub = '0' )
                                          severity                = if_abap_behv_message=>severity-success )
                     %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zladb_i_travel
         IN LOCAL MODE
         ENTITY Travel
         FIELDS ( CustomerId )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY client customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES
                                             MAPPING customer_id = CustomerId
                                             EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    IF NOT lt_customer IS  INITIAL.
      SELECT FROM @lt_customer AS it_cust
             INNER JOIN /dmo/customer AS bd_cust
                   ON it_cust~customer_id EQ bd_cust~customer_id
             FIELDS it_cust~customer_id
             INTO TABLE @DATA(lt_customer_db).
*             ##db_feature_mode[itabs_in_from_clause] ##itab_db_select..
    ENDIF.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF <ls_travel>-CustomerId IS INITIAL
         OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-CustomerId ] ).

        APPEND VALUE #(  TravelId = <ls_travel>-TravelId ) TO failed-travel.
        APPEND VALUE #(  TravelId = <ls_travel>-TravelId
                         %msg = new_message( id        = '/DMO/CM_FLIGHT_LEGAC'
                                             number    = '002'
                                             v1        = <ls_travel>-CustomerId
                                             severity  = if_abap_behv_message=>severity-error )
                         %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDate.

    READ ENTITIES OF zladb_i_travel
         IN LOCAL MODE
         ENTITY Travel
         FIELDS ( BeginDate EndDate )
*         with value #( for <root_key> in keys ( %key = <root_key> ) )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel_result>).

      IF <ls_travel_result>-EndDate < <ls_travel_result>-BeginDate.

        APPEND VALUE #( %key        = <ls_travel_result>-%key
                        TravelId   = <ls_travel_result>-TravelId ) TO failed-travel.

        APPEND VALUE #( %key     = <ls_travel_result>-%key
                        %msg     = new_message( id       = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgid
                                                number   = /dmo/cx_flight_legacy=>end_date_before_begin_date-msgno
                                                v1       = <ls_travel_result>-BeginDate
                                                v2       = <ls_travel_result>-EndDate
                                                v3       = <ls_travel_result>-TravelId
                                                severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF <ls_travel_result>-BeginDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key        = <ls_travel_result>-%key
                        TravelId   = <ls_travel_result>-TravelId ) TO failed-travel.

        APPEND VALUE #( %key = <ls_travel_result>-%key
                        %msg = new_message( id       = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgid
                                            number   = /dmo/cx_flight_legacy=>begin_date_before_system_date-msgno
                                            severity = if_abap_behv_message=>severity-error )
                                            %element-BeginDate = if_abap_behv=>mk-on
*                                            %element-EndDate   = if_abap_behv=>mk-on
                                            ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF zladb_i_travel
         IN LOCAL MODE
         ENTITY Travel
         FIELDS ( OverallStatus )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(lt_travel).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      CASE <ls_travel>-OverallStatus.
        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted

        WHEN OTHERS.
          APPEND VALUE #( %key = <ls_travel>-%key ) TO failed-travel.

          APPEND VALUE #( %key = <ls_travel>-%key
                          %msg = new_message( id       = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                                              number   = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                                              v1       = <ls_travel>-OverallStatus
                                              severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zladb_i_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zladb_i_booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zladb_i_booking~validateStatus.

ENDCLASS.

CLASS lhc_zladb_i_booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.

    IF keys IS NOT INITIAL.
      zcl_ladb_travel_helper=>calculate_price(
        it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                    GROUP BY booking_key-TravelId
                                    WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF zladb_i_travel
       IN LOCAL MODE
       ENTITY Booking
       FIELDS ( TravelId )
       WITH CORRESPONDING #(  keys )
       RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      CASE <ls_travel>-BookingStatus.
        WHEN 'O'.  " Open
        WHEN 'N'.  " New
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted
        WHEN OTHERS.
          APPEND VALUE #( %key = <ls_travel>-%key ) TO failed-travel.

          APPEND VALUE #( %key = <ls_travel>-%key
                          %msg = new_message( id       = /dmo/cx_flight_legacy=>status_is_not_valid-msgid
                                              number   = /dmo/cx_flight_legacy=>status_is_not_valid-msgno
                                              v1       = <ls_travel>-BookingStatus
                                              severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus       = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_zladb_i_booksuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zladb_i_booksuppl~calculateTotalFlightPrice.

ENDCLASS.

CLASS lhc_zladb_i_booksuppl IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.

    IF keys IS NOT INITIAL.
      zcl_ladb_travel_helper=>calculate_price(
        it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                    GROUP BY booking_key-TravelId
                                    WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZLADB_I_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZLADB_I_TRAVEL IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_log TYPE STANDARD TABLE OF zladb_log.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

*    create-
*    delete-
*    update-

    IF NOT create-travel IS INITIAL.
      lt_log = CORRESPONDING #( create-travel MAPPING travel_id = TravelId ).
    ELSEIF NOT update-travel IS INITIAL.
      lt_log = CORRESPONDING #( update-travel MAPPING travel_id = TravelId ).
    ENDIF.

    LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<ls_log_c>).
      GET TIME STAMP FIELD <ls_log_c>-created_at.

      IF NOT create-travel IS INITIAL.
        <ls_log_c>-changing_operation = 'CREATE'.
        READ TABLE create-travel
             WITH TABLE KEY entity
             COMPONENTS TravelId = <ls_log_c>-travel_id
             INTO DATA(ls_travel).
      ELSEIF NOT update-travel IS INITIAL.
        <ls_log_c>-changing_operation = 'UPDATE'.
        READ TABLE update-travel
             WITH TABLE KEY entity
             COMPONENTS TravelId = <ls_log_c>-travel_id
             INTO ls_travel.
      ENDIF.

      IF sy-subrc EQ 0.
        IF ls_travel-%control-BookingFee EQ cl_abap_behv=>flag_changed.
          TRY.
              <ls_log_c>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error INTO DATA(lx_uuid_error).
              "handle exception
              "lx_uuid_error->get_text(  ).
          ENDTRY.
          <ls_log_c>-changed_field_name = 'BookingFee'.
          <ls_log_c>-changed_value = ls_travel-BookingFee.
          <ls_log_c>-user_mod = lv_user.
        ENDIF.
      ENDIF.

    ENDLOOP.

    DELETE lt_log WHERE travel_id IS INITIAL.

    IF NOT lt_log IS INITIAL.
      IF NOT create-travel IS INITIAL OR
         NOT update-travel IS INITIAL.
        MODIFY zladb_log FROM TABLE @lt_log.
      ENDIF.
    ENDIF.

* ****Supplements***with unmanaged save***

    DATA lt_supplements TYPE TABLE OF zladb_booksuppl.

    IF NOT create-bookingsupplement IS INITIAL.
      lt_supplements = CORRESPONDING #( create-bookingsupplement MAPPING travel_id     = %control-TravelId
                                                                         booking_id    = %control-BookingId
                                                                         supplement_id = %control-SupplementId
                                                                         price         = Price
                                                                         currency_code = CurrencyCode ).
      LOOP AT lt_supplements ASSIGNING FIELD-SYMBOL(<ls_supplements>).
        GET TIME STAMP FIELD  <ls_supplements>-last_changed_at.
      ENDLOOP.
      INSERT zladb_booksuppl FROM TABLE @lt_supplements.
    ENDIF.

    IF NOT update-bookingsupplement IS INITIAL.
      lt_supplements = CORRESPONDING #( update-bookingsupplement MAPPING travel_id     = %control-TravelId
                                                                         booking_id    = %control-BookingId
                                                                         supplement_id = %control-SupplementId
                                                                         price         = Price
                                                                         currency_code = CurrencyCode ).
      LOOP AT lt_supplements ASSIGNING <ls_supplements>.
        GET TIME STAMP FIELD  <ls_supplements>-last_changed_at.
      ENDLOOP.
      UPDATE zladb_booksuppl FROM TABLE @lt_supplements.
    ENDIF.

    IF NOT delete-bookingsupplement IS INITIAL.
      lt_supplements = CORRESPONDING #( delete-bookingsupplement MAPPING travel_id     = TravelId
                                                                         booking_id    = BookingId
                                                                         supplement_id = BookingSupplementId ).
      DELETE zladb_booksuppl FROM TABLE @lt_supplements.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
