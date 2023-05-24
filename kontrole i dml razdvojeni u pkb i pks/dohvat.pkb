create or replace NONEDITIONABLE PACKAGE BODY DOHVAT AS
e_iznimka exception;
FILTER_FAILED exception;
------------------------------------------------------------------------------------
--login
 PROCEDURE p_login(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_username   zav_login.korIme%TYPE;
    l_password   zav_login.lozinka%TYPE;
    l_id         zav_login.id%TYPE;
    l_stuid      zav_login.studentID%TYPE;
    l_proid      zav_login.profesorID%TYPE;
    l_out        json_array_t := json_array_t('[]');
 BEGIN
    l_input := in_json.to_string;
    SELECT
        JSON_VALUE(l_input, '$.username' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.password' RETURNING VARCHAR2)
    INTO
        l_username,
        l_password
    FROM
        dual;

    IF (filter.f_check_login(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
       BEGIN
          SELECT
             id, studentID, profesorID
          INTO 
             l_id, l_stuid, l_proid
          FROM
             zav_login
          WHERE
             korIme = l_username AND 
             lozinka = l_password;
       EXCEPTION
             WHEN no_data_found THEN
                l_obj.put('h_message', 'Nepoznato korisnicko ime ili zaporka');
                l_obj.put('h_errcod', 4001);
                RAISE e_iznimka;
             WHEN OTHERS THEN
                RAISE;
       END;

       IF(l_stuid is not null) then
       SELECT
          JSON_OBJECT( 
             'StudentID' VALUE kor.id, 
             'ime' VALUE kor.ime, 
             'prezime' VALUE kor.prezime,
             'ID' VALUE log.id)
       INTO 
          l_record
       FROM
          zav_studenti kor, zav_login log
       WHERE
          kor.id = l_stuid and kor.id=log.studentid;

       else

       SELECT
          JSON_OBJECT( 
             'ProfesorID' VALUE kor.id, 
             'ime' VALUE kor.ime, 
             'prezime' VALUE kor.prezime,
             'ID' VALUE log.id)
       INTO 
          l_record
       FROM
          zav_profesori kor, zav_login log
       WHERE
          kor.id = l_proid and kor.id=log.profesorid;

       end if;


    END IF;

    l_out.append(json_object_t(l_record));
    l_obj.put('data', l_out);
    out_json := l_obj;
 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_login',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_login;





 PROCEDURE p_get_ocjene(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_string     VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_stuid      number;
    l_predmetid  number;
    l_ishodid    number;
    l_out        json_array_t := json_array_t('[]');
    l_page       number; 
    l_perpage    number; 
    l_count      number;
    l_ocjene     json_array_t :=JSON_ARRAY_T('[]');
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    l_string := in_json.TO_STRING; 
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF(biznis.f_valid_student_exists(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
    

    SELECT
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' ),
        JSON_VALUE(l_string, '$.predmetid' ),
        JSON_VALUE(l_string, '$.ishodid' ),
        JSON_VALUE(l_string, '$.studentid')
    INTO
        l_page,
        l_perpage,
        l_predmetid,
        l_ishodid,
        l_stuid
    FROM 
       dual;







    FOR loopvar IN (
            SELECT json_object(
                'ID_PREDMETA' VALUE i.predmetid,
                'IME_PREDMETA' VALUE j.ime,
                'ID_ISHODA' VALUE p.ishodid,
                'IME_ISHODA' VALUE i.ime,
                'POSTOTAK' VALUE p.postotak
                
                ) as izlaz
            from zav_ishodiPolozeni p, 
                 zav_ishodi i, 
                 zav_predmeti j
            where 
                 p.studentid = l_stuid
                 and i.id=p.ishodid 
                 and j.id=i.predmetid
                 and p.ishodid = nvl(l_ishodid, p.ishodid)
                 and i.predmetid = nvl(l_predmetid, i.predmetid)
                 OFFSET NVL(l_page,0)*NVL(l_perpage,10) ROWS FETCH NEXT NVL(l_perpage,10) ROWS ONLY
            )
        LOOP
            l_ocjene.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;






    SELECT
      count(1)
    INTO
       l_count
    from zav_ishodiPolozeni p, 
         zav_ishodi i, 
         zav_predmeti j 
    where 
         p.studentid = l_stuid
         and i.id=p.ishodid 
         and j.id=i.predmetid
         and p.ishodid = nvl(l_ishodid, p.ishodid)
         and i.predmetid = nvl(l_predmetid, i.predmetid);




    l_obj.put('count',l_count);
    l_obj.put('data',l_ocjene);
    out_json := l_obj;
    END IF;

 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_get_ocjene',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_get_ocjene;
 
 PROCEDURE p_get_predmete(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_string     VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_predmetid  number;
    l_profesorid  number;
    l_out        json_array_t := json_array_t('[]');
    l_page       number; 
    l_perpage    number; 
    l_count      number;
    l_data     json_array_t :=JSON_ARRAY_T('[]');
    LOGIN_FAILED exception;
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    l_string := in_json.TO_STRING;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE

    SELECT
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' ),
        JSON_VALUE(l_string, '$.predmetid' ),
        JSON_VALUE(l_string, '$.profesorid' )
    INTO
        l_page,
        l_perpage,
        l_predmetid,
        l_profesorid
    FROM 
       dual;
    l_perpage:=NVL(l_perpage,10);

    FOR loopvar IN (
            SELECT json_object(
                'ID_PREDMETA' VALUE x.id,
                'IME_PREDMETA' VALUE x.ime,
                'ID_PROFESORA' VALUE p.id,
                'IME_PROFESORA' VALUE p.ime,
                'PREZIME_PROFESORA' VALUE p.prezime
                
                ) as izlaz
            from
                zav_profesori p, 
                zav_predmeti x 
            where 
                x.profesorid=p.id and 
                x.id = nvl(l_predmetid, x.id) and 
                p.id = nvl(l_profesorid, p.id)
                OFFSET NVL(l_page,0)*NVL(l_perpage,10) ROWS FETCH NEXT NVL(l_perpage,10) ROWS ONLY
            )
        LOOP
            l_data.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;



SELECT
      count(1)
    INTO
       l_count
from
     zav_profesori p, 
     zav_predmeti x 
where 
     x.profesorid=p.id and x.id = nvl(l_predmetid, x.id) and p.id = nvl(l_profesorid, p.id);
     



    l_obj.put('count',l_count);
    l_obj.put('data',l_data);
    out_json := l_obj;
    END IF;

 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_get_predmete',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_get_predmete;
 
 PROCEDURE p_get_ishode(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_string     VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_predmetid  number;
    l_ishodid    number;
    l_profesorid  number;
    l_out        json_array_t := json_array_t('[]');
    l_page       number; 
    l_perpage    number; 
    l_count      number;
    l_data     json_array_t :=JSON_ARRAY_T('[]');
    LOGIN_FAILED exception;
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    l_string := in_json.TO_STRING;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE

    SELECT
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' ),
        JSON_VALUE(l_string, '$.predmetid' ),
        JSON_VALUE(l_string, '$.ishodid' )
    INTO
        l_page,
        l_perpage,
        l_predmetid,
        l_ishodid
    FROM 
       dual;


    FOR loopvar IN (
            SELECT json_object(
                'ID_PREDMETA' VALUE p.id,
                'IME_PREDMETA' VALUE p.ime,
                'ID_ISHODA' VALUE i.id,
                'IME_ISHODA' VALUE i.ime
                
                ) as izlaz
            from
                zav_ishodi i, 
                zav_predmeti p 
            where 
                p.id=i.predmetid and 
                p.id = nvl(l_predmetid, p.id) and 
                i.id = nvl(l_ishodid, i.id)
                OFFSET NVL(l_page,0)*NVL(l_perpage,10) ROWS FETCH NEXT NVL(l_perpage,10) ROWS ONLY
            )
        LOOP
            l_data.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;


            
            SELECT
                  count(1)
            INTO
                   l_count
            from
                zav_ishodi i, 
                zav_predmeti p 
            where 
                p.id=i.predmetid and 
                p.id = nvl(l_predmetid, p.id) and 
                i.id = nvl(l_ishodid, i.id);
     



    l_obj.put('count',l_count);
    l_obj.put('data',l_data);
    out_json := l_obj;
    END IF;

 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_get_ishode',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_get_ishode;
 
 
 PROCEDURE p_get_studenti(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_string     VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_out        json_array_t := json_array_t('[]');
    l_id         number;
    l_page       number; 
    l_perpage    number; 
    l_count      number;
    l_idstu      number;
    l_data     json_array_t :=JSON_ARRAY_T('[]');
    LOGIN_FAILED exception;
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    l_string := in_json.TO_STRING;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE

    SELECT
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' ),
        JSON_VALUE(l_string, '$.id' ),
        JSON_VALUE(l_string, '$.studentid' )
    INTO
        l_page,
        l_perpage,
        l_id,
        l_idstu
    FROM 
       dual;
    if(l_id is null and l_idstu is not null) then
        l_id:=l_idstu;
    end if;


    FOR loopvar IN (
            SELECT json_object(
                'ID' VALUE id,
                'IME' VALUE ime,
                'PREZIME' VALUE prezime
                
                ) as izlaz
            from
                zav_studenti 
            where 
                id = nvl(l_id, id)
                OFFSET NVL(l_page,0)*NVL(l_perpage,10) ROWS FETCH NEXT NVL(l_perpage,10) ROWS ONLY
            )
        LOOP
            l_data.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;


            
            SELECT
                  count(1)
            INTO
                   l_count
            from
                zav_studenti 
            where 
                id = nvl(l_id, id);
     



    l_obj.put('count',l_count);
    l_obj.put('data',l_data);
    out_json := l_obj;
    END IF;

 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_get_studenti',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_get_studenti;
 
  PROCEDURE p_get_profesori(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_string     VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_out        json_array_t := json_array_t('[]');
    l_id         number;
    l_idprofesor number;
    l_page       number; 
    l_perpage    number; 
    l_count      number;
    l_data     json_array_t :=JSON_ARRAY_T('[]');
    LOGIN_FAILED exception;
 BEGIN
    l_obj := JSON_OBJECT_T(in_json);
    l_string := in_json.TO_STRING;

    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
    
    SELECT
        JSON_VALUE(l_string, '$.page' ),
        JSON_VALUE(l_string, '$.perpage' ),
        JSON_VALUE(l_string, '$.id' ),
        JSON_VALUE(l_string, '$.profesorid' )
    INTO
        l_page,
        l_perpage,
        l_id,
        l_idprofesor
    FROM 
       dual;
    if(l_id is null and l_idprofesor is not null) then
        l_id:=l_idprofesor;
    end if;


    FOR loopvar IN (
            SELECT json_object(
                'ID' VALUE id,
                'IME' VALUE ime,
                'PREZIME' VALUE prezime
                
                ) as izlaz
            from
                zav_profesori 
            where 
                id = nvl(l_id, id)
                OFFSET NVL(l_page,0)*NVL(l_perpage,10) ROWS FETCH NEXT NVL(l_perpage,10) ROWS ONLY
            )
        LOOP
            l_data.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;


            
            SELECT
                  count(1)
            INTO
                   l_count
            from
                zav_profesori 
            where 
                id = nvl(l_id, id);
     



    l_obj.put('count',l_count);
    l_obj.put('data',l_data);
    out_json := l_obj;
    END IF;

 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_get_profesori',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_string);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_get_profesori;
 
END DOHVAT;