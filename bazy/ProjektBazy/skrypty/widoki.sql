delimiter \

create view bilans_całkowity as select sum(x.bilans) as bilans from (select x.nazwa, y.zyski-x.wydatki as bilans  from
(select t.nazwa, d.waga*t.cena_kg_dostawy as wydatki from towary t join
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga
from towary_dostawy d group by d.towary_id_towaru) d
on d.id = t.id_towaru) x join
(select t.nazwa, d.waga*t.cena_kg_sprzedaży as zyski from towary t join
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga
from towary_sprzedaże d group by d.towary_id_towaru) d
on d.id = t.id_towaru) y on x.nazwa = y.nazwa) x
\
create view bilans_towary as select x.nazwa, y.zyski-x.wydatki as bilans  
from (select t.nazwa, d.waga*t.cena_kg_dostawy as wydatki from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_dostawy d group by d.towary_id_towaru) d on d.id = t.id_towaru) x join 
(select t.nazwa, d.waga*t.cena_kg_sprzedaży as zyski from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_sprzedaże d group by d.towary_id_towaru) d on d.id = t.id_towaru) y on x.nazwa = y.nazwa
\
create view zyski_towary as select t.nazwa, d.waga*t.cena_kg_sprzedaży as zyski from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_sprzedaże d group by d.towary_id_towaru) d on d.id = t.id_towaru
\
create view wydatki_towary as select t.nazwa, t.cena_kg_dostawy*d.waga as wydatki from towary t  join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_dostawy d group by d.towary_id_towaru) d on t.id_towaru = d.id
\
CREATE VIEW `dostawcy_dostawy` AS select `k`.`pseudonim` AS `pseudonim`,count(`s`.`id_dostawy`) AS `ilość_dostaw` from 
(`dostawcy` `k` left join `dostawy` `s` on((`k`.`id_dostawcy` = `s`.`dostawcy_id_dostawcy`))) group by `k`.`pseudonim`;
\
CREATE VIEW `wspólnicy_dostawy` AS SELECT `k`.`pseudonim` AS `pseudonim`, COUNT(`d`.`dostawy_id_dostawy`) AS `ilość_dostaw`FROM
(`wspólnicy` `k` LEFT JOIN `towary_dostawy` `d` ON ((`k`.`id_wspólnika` = `d`.`wspólnicy_id_wspólnika`))) GROUP BY `k`.`id_wspólnika`
\
CREATE VIEW `wspólnicy_sprzedaże` AS select `k`.`pseudonim` AS `pseudonim`,count(`d`.`sprzedaże_id_sprzedaży`) AS `ilość_sprzedaży` from 
(`wspólnicy` `k` left join `towary_sprzedaże` `d` on((`k`.`id_wspólnika` = `d`.`wspólnicy_id_wspólnika`))) group by `k`.`id_wspólnika`;
\
CREATE VIEW `klienci_sprzedaże` AS select `k`.`pseudonim` AS `pseudonim`, count(`s`.`id_sprzedaży`) AS `ilość_sprzedaży` from 
(`klienci` `k` left join `sprzedaże` `s` on((`k`.`id_klienta` = `s`.`klienci_id_klienta`))) group by `k`.`pseudonim`;
\
CREATE VIEW `dostawcy_obrót` AS select `k`.`pseudonim` AS `pseudonim`, ifnull(`t`.`obrót`,'0') AS `obrót` from 
(`dostawcy` `k` left join 
(select `k`.`dostawca` AS `dostawca`,sum((`t`.`cena_kg_dostawy` * `k`.`waga`)) AS `obrót` from 
((select `s`.`dostawcy_id_dostawcy` AS `dostawca`,`t`.`towar` AS `towar`,`t`.`waga` AS `waga` from 
((select `towary_dostawy`.`dostawy_id_dostawy` AS `id`,`towary_dostawy`.`towary_id_towaru` AS `towar`,`towary_dostawy`.`waga_towaru` AS `waga` from `towary_dostawy`) `t` join 
`dostawy` `s` on((`t`.`id` = `s`.`id_dostawy`)))) `k` join 
`towary` `t` on((`k`.`towar` = `t`.`id_towaru`))) group by `k`.`dostawca` order by `k`.`dostawca`) `t` on((`k`.`id_dostawcy` = `t`.`dostawca`)));
\
CREATE VIEW `klienci_obrót` AS select `k`.`pseudonim` AS `pseudonim`, ifnull(`t`.`obrót`,'0') AS `obrót` from 
(`klienci` `k` left join 
(select `k`.`klient` AS `klient`,sum((`t`.`cena_kg_sprzedaży` * `k`.`waga`)) AS `obrót` from 
((select `s`.`klienci_id_klienta` AS `klient`,`t`.`towar` AS `towar`,`t`.`waga` AS `waga` from 
((select `towary_sprzedaże`.`sprzedaże_id_sprzedaży` AS `id`,`towary_sprzedaże`.`towary_id_towaru` AS `towar`,`towary_sprzedaże`.`waga_towaru` AS `waga` from `towary_sprzedaże`) `t` join 
`sprzedaże` `s` on((`t`.`id` = `s`.`id_sprzedaży`)))) `k` join `towary` `t` on((`k`.`towar` = `t`.`id_towaru`))) group by `k`.`klient` order by `k`.`klient`) `t` on((`k`.`id_klienta` = `t`.`klient`)));
\
CREATE VIEW `dostawcy_ocena` AS select `k`.`pseudonim` AS `pseudonim`,`ocena_kontrahenta`(`k`.`obrót`) AS `ocena` from 
(select `k`.`pseudonim` AS `pseudonim`,ifnull(`t`.`obrót`,'0') AS `obrót` from (`dostawcy` `k` left join 
(select `k`.`dostawca` AS `dostawca`,sum((`t`.`cena_kg_dostawy` * `k`.`waga`)) AS `obrót` from 
((select `s`.`dostawcy_id_dostawcy` AS `dostawca`,`t`.`towar` AS `towar`,`t`.`waga` AS `waga` from 
((select `towary_dostawy`.`dostawy_id_dostawy` AS `id`,`towary_dostawy`.`towary_id_towaru` AS `towar`,`towary_dostawy`.`waga_towaru` AS `waga` from `towary_dostawy`) `t` join 
`dostawy` `s` on((`t`.`id` = `s`.`id_dostawy`)))) `k` join 
`towary` `t` on((`k`.`towar` = `t`.`id_towaru`))) group by `k`.`dostawca` order by `k`.`dostawca`) `t` on((`k`.`id_dostawcy` = `t`.`dostawca`)))) `k`;
\
CREATE VIEW `klienci_ocena` AS select `k`.`pseudonim` AS `pseudonim`,`ocena_kontrahenta`(`k`.`obrót`) AS `ocena` from 
(select `k`.`pseudonim` AS `pseudonim`,ifnull(`t`.`obrót`,'0') AS `obrót` from (`klienci` `k` left join 
(select `k`.`klient` AS `klient`,sum((`t`.`cena_kg_sprzedaży` * `k`.`waga`)) AS `obrót` from 
((select `s`.`klienci_id_klienta` AS `klient`,`t`.`towar` AS `towar`,`t`.`waga` AS `waga` from 
((select `towary_sprzedaże`.`sprzedaże_id_sprzedaży` AS `id`,`towary_sprzedaże`.`towary_id_towaru` AS `towar`,`towary_sprzedaże`.`waga_towaru` AS `waga` from `towary_sprzedaże`) `t` join 
`sprzedaże` `s` on((`t`.`id` = `s`.`id_sprzedaży`)))) `k` join 
`towary` `t` on((`k`.`towar` = `t`.`id_towaru`))) group by `k`.`klient` order by `k`.`klient`) `t` on((`k`.`id_klienta` = `t`.`klient`)))) `k`;
\
create view wspólnicy_pensja as select pseudonim, rola, przydział_pensji(udział) as pensja from wspólnicy
\
create view ocena_wspólnika as select k.pseudonim, k.ilość_dostaw+l.ilość_sprzedaży as ilość_akcji, ocena_wspólnika(k.ilość_dostaw+l.ilość_sprzedaży) as ocena from 
(SELECT k.pseudonim AS pseudonim, COUNT(d.dostawy_id_dostawy) AS ilość_dostaw FROM
(wspólnicy k LEFT JOIN towary_dostawy d ON ((k.id_wspólnika = d.wspólnicy_id_wspólnika))) GROUP BY k.id_wspólnika) k
join
(select k.pseudonim AS pseudonim,count(d.sprzedaże_id_sprzedaży) AS ilość_sprzedaży from 
(wspólnicy k left join towary_sprzedaże d on((k.id_wspólnika = d.wspólnicy_id_wspólnika))) group by k.id_wspólnika) l
on k.pseudonim = l.pseudonim
\
create view widok_dostaw as select t.id_akcji, tw.nazwa, w.pseudonim as wspólnik, d.pseudonim as dostawca, t.waga_towaru from towary_dostawy t
join (select t.id_dostawy, d.pseudonim from dostawy t 
join dostawcy d on d.id_dostawcy = t.dostawcy_id_dostawcy) d
on d.id_dostawy = t.dostawy_id_dostawy
join wspólnicy w on w.id_wspólnika = t.wspólnicy_id_wspólnika
join towary tw on tw.id_towaru = t.towary_id_towaru
\
create view widok_sprzedaży as select t.id_akcji, tw.nazwa, w.pseudonim as wspólnik, d.pseudonim as klient, t.waga_towaru from towary_sprzedaże t
join (select t.id_sprzedaży, d.pseudonim from sprzedaże t 
join klienci d on d.id_klienta = t.klienci_id_klienta) d
on d.id_sprzedaży = t.sprzedaże_id_sprzedaży
join wspólnicy w on w.id_wspólnika = t.wspólnicy_id_wspólnika
join towary tw on tw.id_towaru = t.towary_id_towaru
\
create view wspólnicy_spotkania as (select distinct x.data_spotkania, x.wspólnik, x.osoba from 
(select t.id_akcji, tw.nazwa, w.pseudonim as wspólnik, d.pseudonim as osoba, d.data_spotkania, t.waga_towaru from towary_dostawy t
join (select t.data_dostawy as data_spotkania, t.id_dostawy, d.pseudonim from dostawy t 
join dostawcy d on d.id_dostawcy = t.dostawcy_id_dostawcy) d
on d.id_dostawy = t.dostawy_id_dostawy
join wspólnicy w on w.id_wspólnika = t.wspólnicy_id_wspólnika
join towary tw on tw.id_towaru = t.towary_id_towaru) x
union
select distinct y.data_spotkania, y.wspólnik, y.osoba from 
(select t.id_akcji, tw.nazwa, w.pseudonim as wspólnik, d.pseudonim as osoba, d.data_spotkania, t.waga_towaru from towary_sprzedaże t
join (select t.data_sprzedaży as data_spotkania, t.id_sprzedaży, d.pseudonim from sprzedaże t 
join klienci d on d.id_klienta = t.klienci_id_klienta) d
on d.id_sprzedaży = t.sprzedaże_id_sprzedaży
join wspólnicy w on w.id_wspólnika = t.wspólnicy_id_wspólnika
join towary tw on tw.id_towaru = t.towary_id_towaru) y) order by data_spotkania desc
\
create view bilans_miesięczny as select rok, polski_miesiąc(miesiąc) as miesiąc, bilans from 
(select rok, miesiąc, sum(zysk) as bilans from (select year(s.data_sprzedaży) as rok, month(s.data_sprzedaży) as miesiąc, t.waga_towaru*x.cena_kg_sprzedaży as zysk
from towary_sprzedaże t join sprzedaże s on s.id_sprzedaży = t.sprzedaże_id_sprzedaży
join towary x on x.id_towaru = t.towary_id_towaru
union all
select year(s.data_dostawy) as rok, month(s.data_dostawy) as miesiąc, -1*cast(t.waga_towaru*x.cena_kg_dostawy as signed) as zysk
from towary_dostawy t join dostawy s on s.id_dostawy = t.dostawy_id_dostawy
join towary x on x.id_towaru = t.towary_id_towaru) x group by rok, miesiąc order by rok desc, miesiąc desc, zysk desc) x
\
create view stan_początkowy as select t.nazwa, t.waga_całkowita+s.sprzedaże-d.dostawy as waga_początkowa, (t.waga_całkowita+s.sprzedaże-d.dostawy)*t.cena_kg_sprzedaży as wartość from towary t
join
(select t.nazwa, d.waga as dostawy from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_dostawy d group by d.towary_id_towaru) d on d.id = t.id_towaru) d on t.nazwa = d.nazwa
join
(select t.nazwa, d.waga as sprzedaże from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_sprzedaże d group by d.towary_id_towaru) d on d.id = t.id_towaru) s on t.nazwa = s.nazwa
\
create view zysk_potencjał as select sum(t.wartość) as wartość_początkowa_magazynu, sum(t.wartość_obecna) as wartość_obecna_magazynu, b.bilans as zysk_rzeczywisty, sum(t.wartość_obecna)+b.bilans-sum(t.wartość) as zysk_potencjalny from 
(select t.nazwa, t.waga_całkowita*t.cena_kg_sprzedaży as wartość_obecna, t.waga_całkowita+s.sprzedaże-d.dostawy as waga_początkowa, (t.waga_całkowita+s.sprzedaże-d.dostawy)*t.cena_kg_sprzedaży as wartość from towary t
join
(select t.nazwa, d.waga as dostawy from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_dostawy d group by d.towary_id_towaru) d on d.id = t.id_towaru) d on t.nazwa = d.nazwa
join
(select t.nazwa, d.waga as sprzedaże from towary t join 
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga from towary_sprzedaże d group by d.towary_id_towaru) d on d.id = t.id_towaru) s on t.nazwa = s.nazwa) t
join
(select sum(x.bilans) as bilans from (select x.nazwa, y.zyski-x.wydatki as bilans  from
(select t.nazwa, d.waga*t.cena_kg_dostawy as wydatki from towary t join
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga
from towary_dostawy d group by d.towary_id_towaru) d
on d.id = t.id_towaru) x join
(select t.nazwa, d.waga*t.cena_kg_sprzedaży as zyski from towary t join
(select d.towary_id_towaru as id, sum(d.waga_towaru) as waga
from towary_sprzedaże d group by d.towary_id_towaru) d
on d.id = t.id_towaru) y on x.nazwa = y.nazwa) x) b
\