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