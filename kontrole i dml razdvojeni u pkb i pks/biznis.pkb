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