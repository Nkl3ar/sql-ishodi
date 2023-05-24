---------------------------------------


--------- ROUTER


---------------------------------------


create or replace NONEDITIONABLE PACKAGE ROUTER AS
    e_iznimka exception;
    procedure p_main(p_in in varchar2, p_out out varchar2);
END ROUTER;







create or replace NONEDITIONABLE PACKAGE BODY ROUTER AS

  procedure p_main(p_in in varchar2, p_out out varchar2) AS
    l_obj JSON_OBJECT_T;
    l_procedura varchar2(128);
  BEGIN
    l_obj := JSON_OBJECT_T(p_in);

    SELECT
        JSON_VALUE(p_in, '$.procedura' RETURNING VARCHAR2)
    INTO
        l_procedura
    FROM DUAL;

    CASE l_procedura

    WHEN 'p_login' THEN
       dohvat.p_login(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_ocjene' THEN
       dohvat.p_get_ocjene(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_predmete' THEN
        dohvat.p_get_predmete(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_ishode' THEN
        dohvat.p_get_ishode(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_studenti' THEN
        dohvat.p_get_studenti(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_get_profesori' THEN
        dohvat.p_get_profesori(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_add_predmet' THEN
       podaci.p_add_predmet(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_add_ishod' THEN
       podaci.p_add_ishod(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_add_student_predmet' THEN
       podaci.p_add_student_predmet(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_set_student_ishod' THEN
       podaci.p_set_student_ishod(JSON_OBJECT_T(p_in), l_obj);
    WHEN 'p_remove_student_predmet' THEN
       podaci.p_remove_student_predmet(JSON_OBJECT_T(p_in), l_obj);

    ELSE
        l_obj.put('h_message', ' Nepoznata metoda ' || l_procedura);
        l_obj.put('h_errcode', 1999);
    END CASE;
    p_out := l_obj.TO_STRING;

  END p_main;
END ROUTER;











---------------------------------------


--------- FILTER


---------------------------------------

create or replace NONEDITIONABLE PACKAGE FILTER AS 

  function f_check_login(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_data(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_predmet(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_nn_predmet(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_ishod(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_student(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_profesor(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_check_postotak(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
END FILTER;











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











---------------------------------------


--------- BIZNIS


---------------------------------------


create or replace NONEDITIONABLE PACKAGE BIZNIS AS 

  function f_valid_creds(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_creds_student(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_creds_profesor(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_predmet(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_predmet_unique_name(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_student_exists(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_ishod_exists(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_ishod_under_professor(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;
  function f_valid_postotak(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean;

END BIZNIS;




create or replace NONEDITIONABLE PACKAGE BODY BIZNIS AS
e_iznimka exception;


  function f_valid_predmet_unique_name(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_idd        number;
    l_ime        VARCHAR2(50);
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    
    SELECT
        JSON_VALUE(l_string, '$.ime' RETURNING VARCHAR2)
    INTO
        l_ime
    FROM
        dual;
        
    BEGIN
        select
            count(1)
        into
            l_idd          
        FROM
             zav_predmeti
          WHERE
             ime=l_ime;
    END;
     if(l_idd!=0) then   
       l_obj.put('h_message', 'Molimo unesite ime koje ne postoji'); 
       l_obj.put('h_errcode', 3001);
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
        COMMON.p_errlog('f_valid_predmet_unique_name',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_predmet_unique_name;

  function f_valid_creds(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_username   zav_login.korIme%TYPE;
      l_password   zav_login.lozinka%TYPE;
      l_id         zav_login.id%TYPE;
      l_idd        zav_login.id%TYPE;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.password' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.id' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password,
        l_id
    FROM
        dual;
    IF (filter.f_check_login(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    BEGIN
          SELECT
             id
          INTO 
             l_idd -- cisto da ne bude blank
          FROM
             zav_login
          WHERE
             korIme = l_username AND 
             lozinka = l_password AND
             id = l_id;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Nepoznato korisnicko ime ili zaporka');
                l_obj.put('h_errcod', 3011);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_valid_creds',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_creds;
  function f_valid_creds_profesor(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_username   zav_login.korIme%TYPE;
      l_password   zav_login.lozinka%TYPE;
      l_profesorid         zav_login.id%TYPE;
      l_idd        zav_login.id%TYPE;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.password' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.profesorid' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password,
        l_profesorid
    FROM
        dual;
    IF (filter.f_check_login(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    
    IF (filter.f_check_profesor(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    BEGIN
          SELECT
             id
          INTO 
             l_idd -- cisto da ne bude blank
          FROM
             zav_login
          WHERE
             korIme = l_username AND 
             lozinka = l_password AND
             profesorid = l_profesorid;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Uneseno korisnicko ime i zaporka se ne podudaraju s profesoridom');
                l_obj.put('h_errcod', 3021);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_valid_creds_profesor',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_creds_profesor;
  function f_valid_creds_student(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_username   zav_login.korIme%TYPE;
      l_password   zav_login.lozinka%TYPE;
      l_studentid         zav_login.id%TYPE;
      l_idd        zav_login.id%TYPE;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    SELECT
        JSON_VALUE(l_string, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.password' RETURNING VARCHAR2),
        JSON_VALUE(l_string, '$.id' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password,
        l_studentid
    FROM
        dual;
    IF (filter.f_check_login(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    IF (filter.f_check_student(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    BEGIN
          SELECT
             id
          INTO 
             l_idd -- cisto da ne bude blank
          FROM
             zav_login
          WHERE
             korIme = l_username AND 
             lozinka = l_password AND
             studentid = l_studentid;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Uneseno korisnicko ime i zaporka se ne podudaraju s student');
                l_obj.put('h_errcod', 3031);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_valid_creds_student',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_creds_student;
  
function f_valid_predmet(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
    l_proid      number;
    l_predmetid      number;
      l_idd        number;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
     
     IF(filter.f_check_nn_predmet(in_json,out_json)) then
        raise FILTER_FAILED;
    end if;
    
    
    SELECT
        JSON_VALUE(l_string, '$.profesorid'),
        JSON_VALUE(l_string, '$.predmetid')
    INTO
        l_proid,
        l_predmetid
    FROM
        dual;
        
        
    BEGIN
          SELECT
             id
          INTO 
             l_idd -- cisto da ne bude blank
          FROM
             zav_predmeti
          WHERE
             id = l_predmetid and profesorid=l_proid;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Nepostoji taj predmet s tim profesorom');
                l_obj.put('h_errcod', 3041);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    

    
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_valid_predmet',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_predmet;
  
function f_valid_student_exists(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_idd        number;
      l_stuid        number;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
     
    IF (filter.f_check_student(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    
    SELECT
        JSON_VALUE(l_string, '$.studentid')
    INTO
        l_stuid
    FROM
        dual;

    BEGIN
          SELECT
             id
          INTO 
             l_idd -- cisto da ne bude blank
          FROM
             zav_studenti
          WHERE
             id = l_stuid;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Taj student ne postoji');
                l_obj.put('h_errcod', 3051);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    

    
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_valid_student_exists',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_student_exists;

function f_valid_ishod_exists(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_idd        number;
      l_id        number;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    
    SELECT
        JSON_VALUE(l_string, '$.ishodid')
    INTO
        l_id
    FROM
        dual;

    BEGIN
          SELECT
             id
          INTO 
             l_idd -- cisto da ne bude blank
          FROM
             zav_ishodi
          WHERE
             id = l_id;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Taj ishod ne postoji');
                l_obj.put('h_errcod', 3061);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    

    
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_valid_ishod_exists',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_ishod_exists;  
  
  function f_ishod_under_professor(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_idd        number;
      l_iddd        number;
      l_id        number;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    
    SELECT
        JSON_VALUE(l_string, '$.ishodid'),
        JSON_VALUE(l_string, '$.profesorid')
    INTO
        l_id,
        l_idd
    FROM
        dual;
        
  
    BEGIN
          SELECT
             id
          INTO 
             l_iddd -- cisto da ne bude blank
          FROM
             zav_ishodi
          WHERE
             predmetid in (select id from zav_predmeti where profesorid=l_idd) and id=l_id;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Taj ishod nije pod tim profesorom');
                l_obj.put('h_errcod', 3071);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
    END;
    

    
    return false;


  EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
        return true;
     WHEN e_iznimka THEN
        out_json := l_obj;
        return true;
     WHEN OTHERS THEN
        COMMON.p_errlog('f_ishod_under_professor',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_ishod_under_professor;  
  
    function f_valid_postotak(in_json in JSON_OBJECT_T, out_json out JSON_OBJECT_T) return boolean AS
      l_obj JSON_OBJECT_T;
      l_string varchar2(4000);
      l_postotak        number;
      FILTER_FAILED exception;
  BEGIN  
     l_obj := JSON_OBJECT_T(in_json);  
     l_string := in_json.TO_STRING;
    
    IF (filter.f_check_data(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    IF (filter.f_check_postotak(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    
    SELECT
        JSON_VALUE(l_string, '$.postotak')
    INTO
    l_postotak
    FROM
        dual;
    IF (l_postotak<0 or l_postotak>100) then
                l_obj.put('h_message', 'Postotak nije postotak');
                l_obj.put('h_errcod', 3081);
                RAISE e_iznimka;
    
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
        COMMON.p_errlog('f_valid_postotak',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
        l_obj.put('h_message', 'Dogodila se greška u obradi podataka!'); 
        l_obj.put('h_errcode', 3999);
        out_json := l_obj;
        return true;

  END f_valid_postotak;  
  
END BIZNIS;







