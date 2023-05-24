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