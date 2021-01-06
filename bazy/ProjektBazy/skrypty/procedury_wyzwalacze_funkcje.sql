delimiter \
CREATE PROCEDURE sprzedaż(in waga int, in id int)  
begin  
update towary 
set towary.waga_całkowita = towary.waga_całkowita - waga 
where towary.id_towaru = id;  end
\
CREATE PROCEDURE dostawa(in waga int, in id int)  
begin  
update towary 
set towary.waga_całkowita = towary.waga_całkowita + waga 
where towary.id_towaru = id;  
end
\
create procedure zmiana_udziału()  
begin 
declare menedżer int;
declare zarządca int;
declare pracownik int;
declare współczynnik decimal(3,2);
select ilosc into menedżer from (select rola, count(id_wspólnika) as ilosc from wspólnicy group by rola) w where w.rola = 'Menedżer';
select ilosc into zarządca from (select rola, count(id_wspólnika) as ilosc from wspólnicy group by rola) w where w.rola = 'Zarządca';
select ilosc into pracownik from (select rola, count(id_wspólnika) as ilosc from wspólnicy group by rola) w where w.rola = 'Pracownik';
set współczynnik = 1.00/((3*menedżer)+(2*zarządca)+(Pracownik));
update wspólnicy set wspólnicy.udział = (1.00-(2*współczynnik*zarządca)-(współczynnik*pracownik)) where wspólnicy.rola = 'Menedżer';
update wspólnicy set wspólnicy.udział = (2*współczynnik) where wspólnicy.rola = 'Zarządca';
update wspólnicy set wspólnicy.udział = (współczynnik) where wspólnicy.rola = 'Pracownik';
end
\
create trigger nowa_dostawa before insert  on towary_dostawy 
for each row  
call dostawa(new.waga_towaru, new.towary_id_towaru)
\
create trigger nowa_sprzedaż  before insert   on towary_sprzedaże  
for each row   
IF   new.waga_towaru > (select waga_całkowita from towary t where t.id_towaru = new.towary_id_towaru) 
THEN    SIGNAL SQLSTATE '45000'     SET MESSAGE_TEXT = 'Zbyt mało towaru w magazynie';     
else 
call sprzedaż(new.waga_towaru, new.towary_id_towaru);  
END IF;
\
create trigger del_sprzedaż before delete on towary_sprzedaże 
for each row  
call dostawa(old.waga_towaru, old.towary_id_towaru)
\
create trigger del_dostawa before delete on towary_dostawy 
for each row 
IF   old.waga_towaru > (select waga_całkowita from towary t where t.id_towaru = old.towary_id_towaru) 
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zbyt mało towaru w magazynie'; 
else 
call sprzedaż(old.waga_towaru, old.towary_id_towaru);  
END IF;
\
create trigger rm_dostawa before delete on dostawy 
for each row  
delete from towary_dostawy 
where towary_dostawy.dostawy_id_dostawy = old.id_dostawy
\
create trigger rm_sprzedaż before delete on sprzedaże 
for each row  
delete from towary_sprzedaże 
where towary_sprzedaże.sprzedaże_id_sprzedaży = old.id_sprzedaży
\
create trigger mod_dostawa before update on dostawy 
for each row 
update towary_dostawy 
set towary_dostawy.dostawy_id_dostawy = new.id_dostawy 
where towary_dostawy.dostawy_id_dostawy = old.id_dostawy
\
create trigger mod_sprzedaż before update on sprzedaże 
for each row 
update towary_sprzedaże 
set towary_sprzedaże.sprzedaże_id_sprzedaży = new.id_sprzedaży 
where towary_sprzedaże.sprzedaże_id_sprzedaży = old.id_sprzedaży
\
create trigger mod_waga_dostawa before update on towary_dostawy 
for each row 
begin 
declare waga_o int; 
declare waga_n int; 
declare waga_c int; 
set waga_o = old.waga_towaru; 
set waga_n = new.waga_towaru; 
set waga_c = (select waga_całkowita from towary t where t.id_towaru = new.towary_id_towaru); 
if waga_n>waga_o then 
call dostawa(new.waga_towaru, new.towary_id_towaru); 
call sprzedaż(old.waga_towaru, old.towary_id_towaru); 
elseif waga_o-waga_n>waga_c THEN 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zbyt mało towaru w magazynie'; 
else 
call dostawa(new.waga_towaru, new.towary_id_towaru); 
call sprzedaż(old.waga_towaru, old.towary_id_towaru); 
end if; 
end
\
create trigger mod_waga_sprzedaż before update on towary_sprzedaże
for each row 
begin 
declare waga_o int; 
declare waga_n int; 
declare waga_c int; 
set waga_o = old.waga_towaru; 
set waga_n = new.waga_towaru; 
set waga_c = (select waga_całkowita from towary t where t.id_towaru = new.towary_id_towaru); 
if waga_n<waga_o then 
call dostawa(new.waga_towaru, new.towary_id_towaru); 
call sprzedaż(old.waga_towaru, old.towary_id_towaru); 
elseif waga_n-waga_o>waga_c THEN 
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zbyt mało towaru w magazynie'; 
else 
call dostawa(old.waga_towaru, old.towary_id_towaru); 
call sprzedaż(new.waga_towaru, new.towary_id_towaru); 
end if; 
end
\
CREATE FUNCTION `ocena_kontrahenta`(obrót int) RETURNS varchar(50)
DETERMINISTIC
begin
declare ocena varchar(50);
if obrót < 1 then
set ocena = 'Nieznajomy';
elseif obrót >= 1 and obrót < 1000 then
set ocena = 'Rzadki kontrahent';
elseif obrót >= 1000 then
set ocena = 'Stały bywalec';
end if;
return ocena;
end
\
CREATE FUNCTION ocena_wspólnika(akcje int) RETURNS varchar(50)
DETERMINISTIC
begin
declare ocena varchar(50);
if akcje < 2 then
set ocena = 'Nierób';
elseif akcje >= 2 and akcje < 4 then
set ocena = 'Przeciętny';
elseif akcje >= 5 then
set ocena = 'Pracowity';
end if;
return ocena;
end;
\
create function przydział_pensji(udział decimal(3,2)) returns int
deterministic
begin
declare pensja int;
declare zysk int;
set zysk = (select sum(x.bilans) as bilans from (select x.nazwa, y.zyski-x.wydatki as bilans  from
(select t.nazwa, d.waga*t.cena_kg_dostawy as wydatki from towary t join
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga
from towary_dostawy d group by d.towary_id_towaru) d
on d.id = t.id_towaru) x join
(select t.nazwa, d.waga*t.cena_kg_sprzedaży as zyski from towary t join
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga
from towary_sprzedaże d group by d.towary_id_towaru) d
on d.id = t.id_towaru) y on x.nazwa = y.nazwa) x);
set pensja = udział*zysk;
return pensja;
end
\
CREATE FUNCTION polski_miesiąc(miesiąc int) RETURNS varchar(50)
DETERMINISTIC
begin
declare nazwa varchar(50);
if miesiąc = '1' then
set nazwa = 'Styczeń';
elseif miesiąc = '2' then
set nazwa = 'Luty';
elseif miesiąc = '3' then
set nazwa = 'Marzec';
elseif miesiąc = '4' then
set nazwa = 'Kwiecień';
elseif miesiąc = '5' then
set nazwa = 'Maj';
elseif miesiąc = '6' then
set nazwa = 'Czerwiec';
elseif miesiąc = '7' then
set nazwa = 'Lipiec';
elseif miesiąc = '8' then
set nazwa = 'Sierpień';
elseif miesiąc = '9' then
set nazwa = 'Wrzesień';
elseif miesiąc = '10' then
set nazwa = 'Październik';
elseif miesiąc = '11' then
set nazwa = 'Listopad';
elseif miesiąc = '12' then
set nazwa = 'Grudzień';
end if;
return nazwa;
end
\
