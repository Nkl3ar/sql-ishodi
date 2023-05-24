
-- dropa tablice
-- nazalost oraclesql nema if exists drop table stoga ce ispisati errore ako te tablice ne postoje
DROP TABLE zav_login;
DROP TABLE zav_ishodiPolozeni;
DROP TABLE zav_ishodi;
DROP TABLE zav_predmeti;
DROP TABLE zav_studenti;
DROP TABLE zav_profesori;
DROP SEQUENCE ZAV_ISHODI_ID_SEQ;
DROP SEQUENCE ZAV_STUDENTI_ID_SEQ;
DROP SEQUENCE ZAV_PROFESORI_ID_SEQ;
DROP SEQUENCE ZAV_PREDMETI_ID_SEQ;
DROP SEQUENCE ZAV_ISHODIPOLOZENI_ID_SEQ;
DROP SEQUENCE ZAV_LOGIN_ID_SEQ;

CREATE TABLE zav_ishodi (
	ID INT NOT NULL,
	ime VARCHAR2(100) NOT NULL,
	predmetID INT NOT NULL,
	constraint ZAV_ISHODI_PK PRIMARY KEY (ID));

CREATE sequence ZAV_ISHODI_ID_SEQ;

CREATE trigger BI_ZAV_ISHODI_ID
  before insert on zav_ishodi
  for each row
begin
  select ZAV_ISHODI_ID_SEQ.nextval into :NEW.ID from dual;
end;

/
CREATE TABLE zav_studenti (
	ID INT NOT NULL,
	ime VARCHAR2(50) NOT NULL,
	prezime VARCHAR2(50) NOT NULL,
	constraint ZAV_STUDENTI_PK PRIMARY KEY (ID));

CREATE sequence ZAV_STUDENTI_ID_SEQ;

CREATE trigger BI_ZAV_STUDENTI_ID
  before insert on zav_studenti
  for each row
begin
  select ZAV_STUDENTI_ID_SEQ.nextval into :NEW.ID from dual;
end;

/
CREATE TABLE zav_profesori (
	ID INT NOT NULL,
	ime VARCHAR2(50) NOT NULL,
	prezime VARCHAR2(50) NOT NULL,
	constraint ZAV_PROFESORI_PK PRIMARY KEY (ID));

CREATE sequence ZAV_PROFESORI_ID_SEQ;

CREATE trigger BI_ZAV_PROFESORI_ID
  before insert on zav_profesori
  for each row
begin
  select ZAV_PROFESORI_ID_SEQ.nextval into :NEW.ID from dual;
end;

/
--profesorid nije unique jer jedan profesor moze biti na vise predmeta
--ime je unique da mi spasi zivce kod procedura
CREATE TABLE zav_predmeti (
	ID INT NOT NULL,
	ime VARCHAR2(50) NOT NULL UNIQUE,
	profesorID INT NOT NULL,
	constraint ZAV_PREDMETI_PK PRIMARY KEY (ID));

CREATE sequence ZAV_PREDMETI_ID_SEQ;

CREATE trigger BI_ZAV_PREDMETI_ID
  before insert on zav_predmeti
  for each row
begin
  select ZAV_PREDMETI_ID_SEQ.nextval into :NEW.ID from dual;
end;

/
--ishodID i studentID sami po sebi nisu unique, ali njihova kombinacija je
CREATE TABLE zav_ishodiPolozeni (
	ID INT NOT NULL,
	ishodID INT NOT NULL,
	studentID INT NOT NULL,
	postotak DECIMAL NOT NULL,
	constraint ZAV_ISHODIPOLOZENI_PK PRIMARY KEY (ID));

CREATE sequence ZAV_ISHODIPOLOZENI_ID_SEQ;

CREATE trigger BI_ZAV_ISHODIPOLOZENI_ID
  before insert on zav_ishodiPolozeni
  for each row
begin
  select ZAV_ISHODIPOLOZENI_ID_SEQ.nextval into :NEW.ID from dual;
end;

/
--preko diy xora jedno korisnicko ime moze biti povezano samo s studentom ili profesorom
CREATE TABLE zav_login (
	ID INT NOT NULL,
	korIme VARCHAR2(255) UNIQUE NOT NULL,
	lozinka VARCHAR2(255) NOT NULL,
	studentID INT UNIQUE,
	profesorID INT UNIQUE,
	constraint ZAV_LOGIN_PK PRIMARY KEY (ID));

CREATE sequence ZAV_LOGIN_ID_SEQ;

CREATE trigger BI_ZAV_LOGIN_ID
  before insert on zav_login
  for each row
begin
  select ZAV_LOGIN_ID_SEQ.nextval into :NEW.ID from dual;
end;

/
-- strani kljucevi
ALTER TABLE zav_ishodi ADD CONSTRAINT zav_ishodi_fk0 FOREIGN KEY (predmetID) REFERENCES zav_predmeti(ID);

ALTER TABLE zav_predmeti ADD CONSTRAINT zav_predmeti_fk0 FOREIGN KEY (profesorID) REFERENCES zav_profesori(ID);

ALTER TABLE zav_ishodiPolozeni ADD CONSTRAINT zav_ishodiPolozeni_fk0 FOREIGN KEY (ishodID) REFERENCES zav_ishodi(ID);
ALTER TABLE zav_ishodiPolozeni ADD CONSTRAINT zav_ishodiPolozeni_fk1 FOREIGN KEY (studentID) REFERENCES zav_studenti(ID);

ALTER TABLE zav_login ADD CONSTRAINT zav_login_fk0 FOREIGN KEY (studentID) REFERENCES zav_studenti(ID);
ALTER TABLE zav_login ADD CONSTRAINT zav_login_fk1 FOREIGN KEY (profesorID) REFERENCES zav_profesori(ID);

-- da postotak bude postotak
ALTER TABLE zav_ishodiPolozeni ADD CONSTRAINT zav_ishodiPolozeni_between CHECK (postotak BETWEEN 0 and 100);

-- XOR mi nije radio u checku, idk zašto
-- ALTER TABLE zav_login ADD CONSTRAINT zav_login_ool CHECK (XOR(studentID IS NULL, profesorID IS NULL));
-- Stoga ga moram raditi ru?no
ALTER TABLE zav_login ADD CONSTRAINT zav_login_ool CHECK ((studentID IS NULL OR profesorID IS NULL) AND (NOT (studentID IS NULL AND profesorID IS NULL)));

-- zav_ishodiPolozeni, samo jedna kombinacija ishodID i studentID smije postojati
ALTER TABLE zav_ishodiPolozeni ADD CONSTRAINT zav_ishodiPolozeni_unq UNIQUE (ishodID,studentID);
-- isto tako za zav_ishodi, samo jedna kombinacija imena i predmetida
ALTER TABLE zav_ishodi ADD CONSTRAINT zav_ishodi_unq UNIQUE (ime,predmetID);


COMMIT;
