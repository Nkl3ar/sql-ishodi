create or replace NONEDITIONABLE PACKAGE DOHVAT AS 
  procedure p_login(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_ocjene(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_predmete(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_ishode(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_studenti(in_json in json_object_t, out_json out json_object_t);
  procedure p_get_profesori(in_json in json_object_t, out_json out json_object_t);
END DOHVAT;