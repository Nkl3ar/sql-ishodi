-- ispis svega iz tablica
SELECT * FROM zav_profesori;
SELECT * FROM zav_studenti;
SELECT * FROM zav_login;
SELECT * FROM zav_predmeti;
SELECT * FROM zav_ishodi;
SELECT * FROM zav_ishodiPolozeni;

-- svi ishodi od predmeta 2
SELECT * FROM zav_ishodi where predmetid=2;
-- svi ishodi koje student 2 polaze/je polozio
SELECT * FROM zav_ishodiPolozeni where studentid=2;
-- svi predmeti koje profesor 4 predaje
SELECT * FROM zav_predmeti where profesorid=4;
-- login, dobili username i password
SELECT * FROM zav_login where korime='cmartinovic' and lozinka='koliko99';
-- grupiranje po profesoridu
select i.profesorid, count(1) from zav_predmeti i group by i.profesorid;

-- detaljan ispis tablice polozeni ishodi, bez imena predmeta
SELECT i.ime as IME_ISHODA, s.ime AS IME, s.prezime, p.postotak from zav_ishodiPolozeni p, zav_ishodi i, zav_studenti s where s.id=p.studentid and i.id=p.ishodid;
-- detaljan ispis tablice polozeni ishodi, s imenom predmeta
SELECT x.ime AS IME_PREDMETA, i.ime as IME_ISHODA, s.ime AS IME, s.prezime, p.postotak from zav_ishodiPolozeni p, zav_ishodi i, zav_studenti s, zav_predmeti x where s.id=p.studentid and i.id=p.ishodid and x.id=i.predmetid;

-- detaljan ispis tablice polozeni ishodi, s imenom predmeta od studenta 2
SELECT 
    x.ime AS IME_PREDMETA,
    i.ime as IME_ISHODA, 
    s.ime AS IME, s.prezime, 
    p.postotak 
from zav_ishodiPolozeni p, 
     zav_ishodi i, 
     zav_studenti s, 
     zav_predmeti x 
where 
     s.id=p.studentid 
     and i.id=p.ishodid 
     and x.id=i.predmetid 
     and p.studentid=2;
     
-- detaljan ispis tablice predmeti, s imenom profesora
SELECT 
    x.ime AS IME_PREDMETA,
    p.ime AS IME, p.prezime
from
     zav_profesori p, 
     zav_predmeti x 
where 
     x.profesorid=p.id;
     
-- detaljan ispis tablice polozeni ishodi, s imenom predmeta od studenta 2 s predmeta 2
SELECT x.ime AS IME_PREDMETA, i.ime as IME_ISHODA, s.ime AS IME, s.prezime, p.postotak from zav_ishodiPolozeni p, zav_ishodi i, zav_studenti s, zav_predmeti x where s.id=p.studentid and i.id=p.ishodid and x.id=i.predmetid and p.studentid=2 and i.predmetid=2;
-- detaljan ispis tablice polozeni ishodi, s imenom predmeta, ispisuje samo ne polozene ishode
SELECT x.ime AS IME_PREDMETA, i.ime as IME_ISHODA, s.ime AS IME, s.prezime, p.postotak from zav_ishodiPolozeni p, zav_ishodi i, zav_studenti s, zav_predmeti x where s.id=p.studentid and i.id=p.ishodid and x.id=i.predmetid and p.postotak < 50;

-- koliko koji profesor ima predmeta
select zav_profesori.ime,zav_profesori.prezime, count(1) as "Broj Predmeta"
from zav_profesori
inner join zav_predmeti on zav_predmeti.profesorid = zav_profesori.id
group by zav_predmeti.profesorid,zav_profesori.ime,zav_profesori.prezime;

-- koliko koji student ima polozenih ishoda
select zav_studenti.ime,zav_studenti.prezime, count(1) as "Broj Polozenih Ishoda"
from zav_studenti
inner join zav_ishodiPolozeni on zav_ishodiPolozeni.studentid=zav_studenti.id where postotak >= 50
group by zav_studenti.id,zav_studenti.ime,zav_studenti.prezime;

-- koliko koji student ima nepolozenih ishoda
select zav_studenti.ime,zav_studenti.prezime, count(1) as "Broj Nepolozenih Ishoda"
from zav_studenti
inner join zav_ishodiPolozeni on zav_ishodiPolozeni.studentid=zav_studenti.id where postotak < 50
group by zav_studenti.id,zav_studenti.ime,zav_studenti.prezime;

-- koliko koji predmet ima ishoda
select zav_predmeti.ime, count(1) as "Broj Ishoda"
from zav_predmeti
inner join zav_ishodi on zav_ishodi.predmetid = zav_predmeti.id
group by zav_predmeti.id,zav_predmeti.ime;

-- koliko koji profesor ima sveukupno ishoda
select zav_profesori.ime,zav_profesori.prezime, count(1) as "Broj Ishoda"
from zav_profesori
inner join zav_predmeti on zav_predmeti.profesorid = zav_profesori.id
inner join zav_ishodi on zav_ishodi.predmetid = zav_predmeti.id
group by zav_predmeti.profesorid,zav_profesori.ime,zav_profesori.prezime;

-- provjera errorloga, precesto sam ga koristio
select * from common.errlog





