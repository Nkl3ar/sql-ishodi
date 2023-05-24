create or replace NONEDITIONABLE PACKAGE PODACI AS 
  procedure p_add_predmet(in_json in json_object_t, out_json out json_object_t);
  procedure p_add_ishod(in_json in json_object_t, out_json out json_object_t);
  procedure p_add_student_predmet(in_json in json_object_t, out_json out json_object_t);
  
  procedure p_set_student_ishod(in_json in json_object_t, out_json out json_object_t);
  
  procedure p_remove_student_predmet(in_json in json_object_t, out_json out json_object_t);

END PODACI;