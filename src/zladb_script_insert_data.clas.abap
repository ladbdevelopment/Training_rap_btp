CLASS zladb_script_insert_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zladb_script_insert_data IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_travel   TYPE TABLE OF zladb_travel,
          lt_booking  TYPE TABLE OF zladb_booking,
          lt_book_sup TYPE TABLE OF zladb_booksuppl.

    SELECT FROM /dmo/travel
         FIELDS travel_id,
                agency_id,
                customer_id,
                begin_date,
                end_date,
                booking_fee,
                total_price,
                currency_code,
                description,
                status AS overall_status,
                createdby,
                createdat,
                lastchangedby,
                lastchangedat
    WHERE travel_id BETWEEN '00000000' AND '00004336'
    INTO CORRESPONDING FIELDS OF TABLE @lt_travel.

    SELECT * FROM /dmo/booking AS booking
           INNER JOIN @lt_travel AS travel
                   ON travel~travel_id EQ booking~travel_id
           INTO CORRESPONDING FIELDS OF TABLE @lt_booking
           ##itab_db_select.

    SELECT * FROM /dmo/book_suppl AS suppl
           INNER JOIN @lt_travel AS travel
                   ON travel~travel_id EQ suppl~travel_id
            INTO CORRESPONDING FIELDS OF TABLE @lt_book_sup.

    DELETE FROM: zladb_travel,
                 zladb_booking,
                 zladb_booksuppl.
    INSERT:
        zladb_travel    FROM TABLE @lt_travel,
        zladb_booking   FROM TABLE @lt_booking,
        zladb_booksuppl FROM TABLE @lt_book_sup.

    out->write( sy-dbcnt ).
    out->write( 'DONE!' ).

  ENDMETHOD.
ENDCLASS.
