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