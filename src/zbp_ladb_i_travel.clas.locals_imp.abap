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
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD acceptTravel.
  ENDMETHOD.

  METHOD createTravelByTemplate.

* EML --> Entity Manipulation Language

    READ ENTITIES OF zladb_i_travel
       IN LOCAL MODE
       ENTITY Travel
       FIELDS ( TravelId
                AgencyId
                CustomerId
                BookingFee
                TotalPrice
                CurrencyCode )
       WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
       RESULT DATA(lt_entity_travel)
       FAILED failed
       REPORTED reported.

  ENDMETHOD.

  METHOD rejectTravel.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDate.
  ENDMETHOD.

  METHOD validateStatus.
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
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zladb_i_booksuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zladb_i_booksuppl~calculateTotalFlightPrice.

ENDCLASS.

CLASS lhc_zladb_i_booksuppl IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZLADB_I_TRAVEL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZLADB_I_TRAVEL IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
