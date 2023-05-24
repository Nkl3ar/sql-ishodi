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