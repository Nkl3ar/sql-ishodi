create or replace NONEDITIONABLE PACKAGE BODY FILTER AS
e_iznimka exception;
  function f_check_login(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_username   zav_login.korIme%TYPE;
      l_password   zav_login.lozinka%TYPE;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.password' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password
    FROM
        dual;

    if (nvl(l_username, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite korisnicko ime'); 
       l_obj.put('h_errcode', 2011);
       raise e_iznimka;
    end if;

    if (nvl(l_password, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite lozinku'); 
       l_obj.put('h_errcode', 2012);
       raise e_iznimka;
    end if;

    return false;

  EXCEPTION
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_login',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_login;
  
function f_check_student(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_stuid   number;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.studentid')
    INTO
        l_stuid
    FROM
        dual;

    if (l_stuid IS NULL) then   
       l_obj.put('h_message', 'Molimo unesite id studenta'); 
       l_obj.put('h_errcode', 2021);
       raise e_iznimka;
    end if;

    return false;

  EXCEPTION
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_student',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_student;
  
  function f_check_data(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
  l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
     l_page  varchar2(40);
     l_perpage varchar2(40);
     l_id varchar2(40);
     l_predmetid  varchar2(40);
     l_profesorid  varchar2(40);
     l_ishodid varchar2(40);
     l_studentid  varchar2(40);
     l_postotak  varchar2(40);
     dataexcept exception;
     negative exception;
      
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT 
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' ),
        JSON_VALUE(l_string, '$.predmetid' ),
        JSON_VALUE(l_string, '$.profesorid' ),
        JSON_VALUE(l_string, '$.ishodid'  ),
        JSON_VALUE(l_string, '$.studentid'),
        JSON_VALUE(l_string, '$.id' ),
        JSON_VALUE(l_string, '$.postotak' )
    INTO
        l_page,
        l_perpage,
        l_predmetid,
        l_profesorid,
        l_ishodid,
        l_studentid,
        l_id,
        l_postotak
    FROM
        dual;

    if (VALIDATE_CONVERSION(nvl(l_page, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_perpage, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_id, 0) AS NUMBER) = 0) then  
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_predmetid, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_profesorid, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_ishodid, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_studentid, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (VALIDATE_CONVERSION(nvl(l_postotak, 0) AS NUMBER) = 0) then
       raise e_iznimka;
    elsif (ROUND(nvl(l_page, 0), 0) != nvl(l_page, 0)) then
       raise dataexcept;
    elsif (ROUND(nvl(l_perpage, 0), 0) != nvl(l_perpage, 0)) then
       raise dataexcept;
    elsif (ROUND(nvl(l_id, 0), 0) != nvl(l_id, 0)) then
       raise dataexcept;
    elsif (ROUND(nvl(l_predmetid, 0), 0) != nvl(l_predmetid, 0)) then
       raise dataexcept;
    elsif (ROUND(nvl(l_profesorid, 0), 0) != nvl(l_profesorid, 0)) then
       raise dataexcept;
    elsif (ROUND(nvl(l_ishodid, 0), 0) != nvl(l_ishodid, 0)) then
       raise dataexcept;
    elsif (ROUND(nvl(l_studentid, 0), 0) != nvl(l_studentid, 0)) then
       raise dataexcept;
    elsif ((nvl(l_page, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_perpage, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_predmetid, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_profesorid, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_ishodid, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_studentid, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_id, 0)) < 0) then
       raise negative;
    elsif ((nvl(l_postotak, 0)) < 0) then
       raise negative;
    end if;


    return false;

  EXCEPTION
     WHEN negative THEN
        l_obj.put('h_message', 'Neki od unešenih idova/page/perpage je negativan.'); 
        l_obj.put('h_errcode', 2033);
        out_json := l_obj;
        return true;
     WHEN dataexcept THEN
        l_obj.put('h_message', 'Neki od unešenih idova/page/perpage nije cijeli broj.'); 
        l_obj.put('h_errcode', 2032);
        out_json := l_obj;
        return true;
     WHEN e_iznimka THEN
        l_obj.put('h_message', 'Neki od unešenih idova/page/perpage/postotak nije broj?an.'); 
        l_obj.put('h_errcode', 2031);
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_data',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_data;

  function f_check_predmet(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_ime        VARCHAR2(50);
      l_proid      zav_login.profesorID%TYPE;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
     
    SELECT
        JSON_VALUE(l_string, '$.profesorid'),
        JSON_VALUE(l_string, '$.ime')
    INTO
        l_proid,
        l_ime
    FROM
        dual;
    
    if (nvl(l_proid, NULL) is null) then   
       l_obj.put('h_message', 'Molimo unesite id profesora'); 
       l_obj.put('h_errcode', 2041);
       raise e_iznimka;
    end if;

    if (nvl(l_ime, ' ') = ' ') then   
       l_obj.put('h_message', 'Molimo unesite ime'); 
       l_obj.put('h_errcode', 2042);
       raise e_iznimka;
    end if;

    return false;

  EXCEPTION
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_predmet',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_predmet;
  

  
function f_check_ishod(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      FILTER_FAILED exception;
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_predmetid number;
      l_count number;
      l_ime   VARCHAR2(50);
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.predmetid' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.ime')
    INTO
        l_predmetid,
        l_ime
    FROM
        dual;

    if (l_predmetid IS NULL) then   
       l_obj.put('h_message', 'Molimo unesite id predmeta'); 
       l_obj.put('h_errcode', 2051);
       raise e_iznimka;
    end if;

    SELECT
      count(1)
    INTO
       l_count
    from 
         zav_predmeti x 
    where 
         x.id = l_predmetid;
     
     if(l_count=0) then   
       l_obj.put('h_message', 'Molimo unesite id predmeta koji postoji'); 
       l_obj.put('h_errcode', 2052);
       raise e_iznimka;
    end if;
    
    IF (filter.f_check_predmet(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    end if;
    
    SELECT
      count(1)
    INTO
       l_count
    from 
         zav_ishodi 
    where 
         predmetid = l_predmetid and ime = l_ime;
     
     if(l_count=1) then   
       l_obj.put('h_message', 'Taj ishod vec postoji'); 
       l_obj.put('h_errcode', 2053);
       raise e_iznimka;
    end if;
    
    

    return false;

  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_ishod',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_ishod;
  
  function f_check_profesor(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_stuid   number;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.profesorid')
    INTO
        l_stuid
    FROM
        dual;

    if (l_stuid IS NULL) then   
       l_obj.put('h_message', 'Molimo unesite id profesora'); 
       l_obj.put('h_errcode', 2061);
       raise e_iznimka;
    end if;

    return false;

  EXCEPTION
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_profesor',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_profesor;
  
  function f_check_nn_predmet(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_proid      zav_login.profesorID%TYPE;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
     
    SELECT
        JSON_VALUE(l_string, '$.profesorid')
    INTO
        l_proid
    FROM
        dual;
    
    if (nvl(l_proid, NULL) is null) then   
       l_obj.put('h_message', 'Molimo unesite id profesora'); 
       l_obj.put('h_errcode', 2071);
       raise e_iznimka;
    end if;

    return false;

  EXCEPTION
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_nn_predmet',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_nn_predmet;
  
function f_check_postotak(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_stuid   number;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.postotak')
    INTO
        l_stuid
    FROM
        dual;

    if (l_stuid IS NULL) then   
       l_obj.put('h_message', 'Molimo unesite postotak'); 
       l_obj.put('h_errcode', 2081);
       raise e_iznimka;
    end if;

    return false;

  EXCEPTION
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_check_postotak',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 2999);
        out_json := l_obj;
        return true;

  END f_check_postotak;
END FILTER;