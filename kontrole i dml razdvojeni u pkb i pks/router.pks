create or replace NONEDITIONABLE PACKAGE ROUTER AS
    e_iznimka exception;
    procedure p_main(p_in in varchar2, p_out out varchar2);
END ROUTER;