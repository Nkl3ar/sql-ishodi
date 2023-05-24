# sql-ishodi
Ovo je projekt koji sam napravio za predmet Baze Podataka. 
U sklopu tog predmeta sam kreirao sustav za spremanje ocjena iz svakog ishoda.
Koristili smo Oracle DBMS.

Također sam ovu bazu spojio s svojim projektom iz Web Programiranja, ali taj projekt je nažalost izgubljen.

Projekt je predan 22. veljače. 2023.

# Tablice

# zav_studenti

Sadrži ime i prezime studenta. Razmišljao sam o dodavanju dodatnih informacija poput JMBAG, OIB, datum rođenja...
Ali na kraju nisam kako bi održao jednostavnost testnog unosa podataka.

# zav_profesori

Isto kao zav_studenti.

# zav_predmeti

Sadrži predmete, ime je unique kako bi si olakšao pri pisanju procedura. Svaki predmet je povezan s jednim profesorom. Da danas pišem imao bih dodatnu tablicu za spajanje profesora s predmetom jer većina predmeta nema samo jednog profesora.


# zav_ishodi

Sadrži ishode, svaki ishod je povezan s nekim predmetom.

# zav_ishodiPolozeni

Sadrži ocjene ishoda za svakog studenta. Zbog toga kako je web dio bio izgrađen, pri dodavanju novih studenata na predmet/novih ishoda primorani smo dodavati inicijalne vrijednosti u tablicu.

# zav_login 

Sadrži korisničko ime i lozinku svakog korisnika. Nažalost napisano je u plaintextu, da danas to radim barem bih hashirao. 
Svako korisničko ime može biti povezano ili s studentom ili s profesorom.
Svaki student i profesor smije imati samo jedno korisničko ime i lozinku.


# Procedure

Ovaj projekt sadrži velik broj procedura, neke su redundatne jer sam morao raditi izmjene na projektu.
Postoje input filter i validation procedure, razne procedure dohvaćanja podataka, dodavanja podataka, jedna za brisanje...
