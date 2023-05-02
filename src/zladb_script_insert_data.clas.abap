class zladb_script_insert_data definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

  protected section.
  private section.
ENDCLASS.



CLASS ZLADB_SCRIPT_INSERT_DATA IMPLEMENTATION.


  method if_oo_adt_classrun~main.

    data: lt_travel   type table of zcol_travel,
          lt_booking  type table of zcol_booking,
          lt_book_sup type table of zcol_booksuppl.

    select from /dmo/travel
         fields travel_id,
                agency_id,
                customer_id,
                begin_date,
                end_date,
                booking_fee,
                total_price,
                currency_code,
                description,
                status as overall_status,
                createdby,
                createdat,
                lastchangedby,
                lastchangedat
    where travel_id between '00000010' and '00000040'
    into corresponding fields of table @lt_travel.

    select * from /dmo/booking as booking
           inner join @lt_travel as travel
                   on travel~travel_id eq booking~travel_id
           into corresponding fields of table @lt_booking
           ##itab_db_select.

    select * from /dmo/book_suppl as suppl
           inner join @lt_travel as travel
                   on travel~travel_id eq suppl~travel_id
            into corresponding fields of table @lt_book_sup.

    delete from: zcol_travel,
                 zcol_booking,
                 zcol_booksuppl.
    insert:
        zladb_travel    from table @lt_travel,
        zladb_booking   from table @lt_booking,
        zladb_booksuppl from table @lt_book_sup.

    out->write( sy-dbcnt ).
    out->write( 'DONE!' ).

  endmethod.
ENDCLASS.
