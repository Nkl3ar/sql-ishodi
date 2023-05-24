---------------------------------------


--------- DOHVAT


---------------------------------------

create or replace NONEDITIONABLE PACKAGE DOHVAT AS 
  procedure p_login(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_ocjene(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_predmete(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_ishode(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_studenti(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_profesori(in_json in json_object_t, out_json out json_object_t);
END DOHVAT;







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






---------------------------------------


--------- PODACI


---------------------------------------




create or replace NONEDITIONABLE PACKAGE PODACI AS 
  procedure p_add_predmet(in_json in json_object_t, out_json out json_object_t);
  procedure p_add_ishod(in_json in json_object_t, out_json out json_object_t);
  procedure p_add_student_predmet(in_json in json_object_t, out_json out json_object_t);
  
  procedure p_set_student_ishod(in_json in json_object_t, out_json out json_object_t);
  
  procedure p_remove_student_predmet(in_json in json_object_t, out_json out json_object_t);

END PODACI;













create or replace NONEDITIONABLE PACKAGE BODY PODACI AS
e_iznimka exception;



 PROCEDURE p_add_predmet(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_ime        VARCHAR2(50);
    l_proid      number;
    l_id         number;
    l_out        json_array_t := json_array_t('[]');
    l_data       json_array_t :=JSON_ARRAY_T('[]');
    FILTER_FAILED exception;
 BEGIN
    l_input := in_json.to_string;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
	END IF;
    
    SELECT
        JSON_VALUE(l_input, '$.profesorid'),
        JSON_VALUE(l_input, '$.ime')
    INTO
        l_proid,
        l_ime
    FROM
        dual;

    IF (biznis.f_valid_creds_profesor(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (filter.f_check_predmet(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_valid_predmet_unique_name(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
        INSERT INTO zav_predmeti(ime,profesorID) VALUES (l_ime,l_proid);
    END IF;
    l_obj.put('h_message', 'Predmet je uspješno dodan');
    l_obj.put('h_errcode', 0);

    FOR loopvar IN (
            SELECT json_object(
                'ID_PREDMETA' VALUE x.id
                
                ) as izlaz
            from
                zav_predmeti x 
            where 
                x.profesorid = l_proid and
                x.ime = l_ime
            )
        LOOP
            l_data.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;

    l_obj.put('data',l_data);
    out_json := l_obj;
    commit;
 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_add_predmet',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_add_predmet;
 
 
 PROCEDURE p_add_ishod(in_json in json_object_t, out_json out json_object_t )AS
    l_data       json_array_t :=JSON_ARRAY_T('[]');
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_ime        VARCHAR2(50);
    l_proid      number;
    l_predmetid      number;
    l_out        json_array_t := json_array_t('[]');
    l_ishodid    number;
    FILTER_FAILED exception;
 BEGIN
    l_input := in_json.to_string;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
	END IF;
    
    SELECT
        JSON_VALUE(l_input, '$.profesorid' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.predmetid' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.ime' RETURNING VARCHAR2)
    INTO
        l_proid,
        l_predmetid,
        l_ime
    FROM
        dual;
        
    IF (biznis.f_valid_creds_profesor(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;
    IF (filter.f_check_ishod(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_valid_predmet(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
        INSERT INTO zav_ishodi(ime,predmetID) VALUES (l_ime,l_predmetid);
        
        select
            id into l_ishodid
        from
            zav_ishodi
        where
            ime=l_ime and predmetid = l_predmetid;
        
        FOR loopvar IN (
            select 
                distinct studentid as izlaz
            from 
                zav_ishodiPolozeni 
            where 
                ishodid in (
                    select 
                        zav_ishodi.id
                    from 
                        zav_predmeti 
                        inner join 
                            zav_ishodi 
                            on zav_ishodi.predmetid = zav_predmeti.id
                    where zav_predmeti.id=l_predmetid)
            )
        LOOP
            INSERT INTO zav_ishodiPolozeni(ishodID,studentID,postotak) VALUES (l_ishodid, loopvar.izlaz, 0);
        END LOOP;
        
        
        
    END IF;
    l_obj.put('h_message', 'Ishod je uspješno dodan');
    l_obj.put('h_errcode', 0);
    
    
    FOR loopvar IN (
            SELECT json_object(
                'ID_ISHODA' VALUE x.id
                
                ) as izlaz
            from
                zav_ishodi x 
            where 
                x.predmetid = l_predmetid and
                x.ime = l_ime
            )
        LOOP
            l_data.append(JSON_OBJECT_T(loopvar.izlaz));
        END LOOP;

    l_obj.put('data',l_data);

    out_json := l_obj;
    commit;
 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_add_ishod',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_add_ishod;
 
 
 
  
 PROCEDURE p_add_student_predmet(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_ime        VARCHAR2(50);
    l_proid      number;
    l_predmetid      number;
    l_stuid      number;
    l_out        json_array_t := json_array_t('[]');
    l_ishodid    number;
    FILTER_FAILED exception;
 BEGIN
    l_input := in_json.to_string;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
	END IF;
    
    SELECT
        JSON_VALUE(l_input, '$.profesorid' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.predmetid' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.studentid' RETURNING VARCHAR2)
    INTO
        l_proid,
        l_predmetid,
        l_stuid
    FROM
        dual;
        
    IF (biznis.f_valid_creds_profesor(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;

    IF (biznis.f_valid_predmet(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_valid_student_exists(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
        
        FOR loopvar IN (
                select id as izlaz from zav_ishodi where predmetid=l_predmetid
            )
        LOOP
            INSERT INTO zav_ishodiPolozeni(ishodID,studentID,postotak) VALUES (loopvar.izlaz, l_stuid, 0);
        END LOOP;
        
        
        
    END IF;
    l_obj.put('h_message', 'Student je uspješno dodan na predmet');
    l_obj.put('h_errcode', 0);

    out_json := l_obj;
    commit;
 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN DUP_VAL_ON_INDEX THEN
       l_obj.put('h_message', 'Student je vec na predmetu');
       l_obj.put('h_errcode', 4031);
       ROLLBACK;
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_add_student_predmet',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_add_student_predmet;
 
 
 
   
 PROCEDURE p_remove_student_predmet(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_ime        VARCHAR2(50);
    l_proid      number;
    l_predmetid      number;
    l_stuid      number;
    l_out        json_array_t := json_array_t('[]');
    l_ishodid    number;
    FILTER_FAILED exception;
 BEGIN
    l_input := in_json.to_string;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
	END IF;
    SELECT
        JSON_VALUE(l_input, '$.profesorid' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.predmetid' RETURNING VARCHAR2),
        JSON_VALUE(l_input, '$.studentid' RETURNING VARCHAR2)
    INTO
        l_proid,
        l_predmetid,
        l_stuid
    FROM
        dual;
        
    IF (biznis.f_valid_creds_profesor(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;

    IF (biznis.f_valid_predmet(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_valid_student_exists(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
        
        FOR loopvar IN (
                select id as izlaz from zav_ishodi where predmetid=l_predmetid
            )
        LOOP
            DELETE FROM zav_ishodiPolozeni where ishodID=loopvar.izlaz and studentID=l_stuid;
        END LOOP;
        
        
        
    END IF;
    l_obj.put('h_message', 'Student je uspješno ispisan s predmeta');
    l_obj.put('h_errcode', 0);

    out_json := l_obj;
    commit;
 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj; 
    WHEN OTHERS THEN
       COMMON.p_errlog('p_remove_student_predmet',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_remove_student_predmet;
 
 
 PROCEDURE p_set_student_ishod(in_json in json_object_t, out_json out json_object_t )AS
    l_obj        json_object_t := json_object_t();
    l_input      VARCHAR2(4000);
    l_record     VARCHAR2(4000);
    l_ime        VARCHAR2(50);
    l_proid      number;
    l_ishodid    number;
    l_stuid      number;
    l_out        json_array_t := json_array_t('[]');
    
    l_postotak  zav_ishodiPolozeni.postotak%TYPE;
    FILTER_FAILED exception;
 BEGIN
    l_input := in_json.to_string;
    IF (filter.f_check_data(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
	END IF;
    
    SELECT
        JSON_VALUE(l_input, '$.profesorid' RETURNING number),
        JSON_VALUE(l_input, '$.ishodid' RETURNING number),
        JSON_VALUE(l_input, '$.studentid' RETURNING number),
        JSON_VALUE(l_input, '$.postotak')
    INTO
        l_proid,
        l_ishodid,
        l_stuid,
        l_postotak
    FROM
        dual;
        
    IF (biznis.f_valid_creds_profesor(in_json, out_json)) THEN
         RAISE FILTER_FAILED;
    END IF;

    IF (biznis.f_valid_ishod_exists(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_valid_student_exists(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_ishod_under_professor(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSIF (biznis.f_valid_postotak(in_json, out_json)) THEN
       RAISE FILTER_FAILED;
    ELSE
            UPDATE zav_ishodiPolozeni set postotak=l_postotak where studentID = l_stuid and ishodID = l_ishodid;
    END IF;
        
        

    l_obj.put('h_message', 'Studentu je uspjesno izmjenjen postotak na predmetu');
    l_obj.put('h_errcode', 0);

    out_json := l_obj;
    commit;
 EXCEPTION
    WHEN FILTER_FAILED THEN
        out_json := out_json; 
    WHEN e_iznimka THEN
       out_json := l_obj;
    WHEN OTHERS THEN
       COMMON.p_errlog('p_set_student_ishod',dbms_utility.format_error_backtrace,SQLCODE,SQLERRM, l_input);
       l_obj.put('h_message', 'Greška u obradi podataka');
       l_obj.put('h_errcode', 4999);
       ROLLBACK;
 END p_set_student_ishod;
 
 
 


END PODACI;