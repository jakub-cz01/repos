delimiter \
CREATE TABLE IF NOT EXISTS `wspólnicy` (
  `id_wspólnika` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pseudonim` VARCHAR(100) NOT NULL,
  `rola` ENUM("Menedżer", "Zarządca", "Pracownik") NOT NULL,
  `udział` DECIMAL(3,2) NOT NULL,
  PRIMARY KEY (`id_wspólnika`))
\
CREATE TABLE IF NOT EXISTS `towary` (
  `id_towaru` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nazwa` VARCHAR(50) NOT NULL,
  `waga_całkowita` INT UNSIGNED NOT NULL,
  `cena_kg_dostawy` INT UNSIGNED NOT NULL,
  `cena_kg_sprzedaży` INT NOT NULL,
  PRIMARY KEY (`id_towaru`))
\
CREATE TABLE IF NOT EXISTS `klienci` (
  `id_klienta` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pseudonim` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_klienta`))
\
CREATE TABLE IF NOT EXISTS `sprzedaże` (
  `id_sprzedaży` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `klienci_id_klienta` INT UNSIGNED NOT NULL,
  `data_sprzedaży` DATE NOT NULL,
  PRIMARY KEY (`id_sprzedaży`, `klienci_id_klienta`),
  CONSTRAINT `fk_sprzedaże_klienci1`
    FOREIGN KEY (`klienci_id_klienta`)
    REFERENCES `klienci` (`id_klienta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
\
CREATE TABLE IF NOT EXISTS `dostawcy` (
  `id_dostawcy` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pseudonim` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_dostawcy`))
\
CREATE TABLE IF NOT EXISTS `dostawy` (
  `id_dostawy` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `dostawcy_id_dostawcy` INT UNSIGNED NOT NULL,
  `data_dostawy` DATE NOT NULL,
  PRIMARY KEY (`id_dostawy`, `dostawcy_id_dostawcy`),
  CONSTRAINT `fk_dostawy_dostawcy1`
    FOREIGN KEY (`dostawcy_id_dostawcy`)
    REFERENCES `dostawcy` (`id_dostawcy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
\
CREATE TABLE IF NOT EXISTS `towary_dostawy` (
  `id_akcji` INT NOT NULL AUTO_INCREMENT,
  `towary_id_towaru` INT UNSIGNED NOT NULL,
  `dostawy_id_dostawy` INT UNSIGNED NOT NULL,
  `wspólnicy_id_wspólnika` INT UNSIGNED NOT NULL,
  `waga_towaru` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_akcji`, `towary_id_towaru`, `dostawy_id_dostawy`, `wspólnicy_id_wspólnika`),
  CONSTRAINT `fk_towary_has_dostawy_towary1`
    FOREIGN KEY (`towary_id_towaru`)
    REFERENCES `towary` (`id_towaru`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_towary_has_dostawy_dostawy1`
    FOREIGN KEY (`dostawy_id_dostawy`)
    REFERENCES `dostawy` (`id_dostawy`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_towary_dostawy_wspólnicy1`
    FOREIGN KEY (`wspólnicy_id_wspólnika`)
    REFERENCES `wspólnicy` (`id_wspólnika`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
\
CREATE TABLE IF NOT EXISTS `towary_sprzedaże` (
  `id_akcji` INT NOT NULL AUTO_INCREMENT,
  `towary_id_towaru` INT UNSIGNED NOT NULL,
  `sprzedaże_id_sprzedaży` INT UNSIGNED NOT NULL,
  `wspólnicy_id_wspólnika` INT UNSIGNED NOT NULL,
  `waga_towaru` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_akcji`, `towary_id_towaru`, `sprzedaże_id_sprzedaży`, `wspólnicy_id_wspólnika`),
  CONSTRAINT `fk_towary_has_sprzedaże_towary1`
    FOREIGN KEY (`towary_id_towaru`)
    REFERENCES `towary` (`id_towaru`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_towary_has_sprzedaże_sprzedaże1`
    FOREIGN KEY (`sprzedaże_id_sprzedaży`)
    REFERENCES `sprzedaże` (`id_sprzedaży`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_towary_sprzedaże_wspólnicy1`
    FOREIGN KEY (`wspólnicy_id_wspólnika`)
    REFERENCES `wspólnicy` (`id_wspólnika`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
\
INSERT INTO klienci (pseudonim) VALUES  ('Mati'),  ('Seba'),  ('Adi'),  ('Mały'),     ('Kucharz'),  ('Gruby'),     ('Ibra'),  ('Piter'),     ('Piston'),  ('Łysy'),     ('Owca'),  ('Rudy')
\
INSERT INTO dostawcy (pseudonim) VALUES  ('Dmitrij'),  ('Sergiej'),  ('Wasilij'),     ('Bazyli'),     ('Michaił'),     ('Iwan'),     ('Olgierd'),     ('Aleksiej'),     ('Oleg'),     ('Jurij'),     ('Władimir')
\
INSERT INTO towary (nazwa, waga_całkowita, cena_kg_dostawy, cena_kg_sprzedaży) VALUES  ('towar_1', '100', '20', '50'),  ('towar_2', '90', '30', '70'),     ('towar_3', '45', '40', '60'),     ('towar_4', '50', '35', '80'),     ('towar_5', '40', '55', '75'),     ('towar_6', '30', '35', '55'),     ('towar_7', '65', '90', '110'),     ('towar_8', '70', '10', '30'),     ('towar_9', '100', '15', '50'),     ('towar_10', '25', '25', '40'),     ('towar_11', '20', '10', '30'),     ('towar_12', '30', '45', '80')
\
INSERT INTO wspólnicy (pseudonim, rola, udział) VALUES  ('Zeus', 'Menedżer', '0.16'),  ('Terminator', 'Zarządca', '0.12'),  ('Gandalf', 'Zarządca', '0.12'),     ('Krzychu', 'Pracownik', '0.06'),  ('Kadet', 'Pracownik', '0.06'),     ('Masa', 'Pracownik', '0.06'),  ('Smerf', 'Pracownik', '0.06'),     ('Cezar', 'Pracownik', '0.06'),  ('Mars', 'Pracownik', '0.06'),     ('Herkules', 'Pracownik', '0.06'),  ('Harry', 'Pracownik', '0.06'),     ('Kiler', 'Pracownik', '0.06'),  ('Maniek', 'Pracownik', '0.06')
\
insert into dostawy (dostawcy_id_dostawcy, data_dostawy) values ('1', '2020-09-01'), ('3', '2020-08-15'), ('3', '2020-09-02'), ('4', '2020-11-15'), ('6', '2020-12-10'), ('7', '2020-07-19'), ('7', '2020-09-09'), ('8', '2020-08-15'), ('10', '2021-01-02'), ('11', '2020-06-11'), ('11', '2020-07-18'), ('11', '2020-10-25')
\
insert into towary_dostawy (towary_id_towaru, dostawy_id_dostawy, wspólnicy_id_wspólnika, waga_towaru) values ('2', '1', '5', '10'), ('1', '1', '5', '15'), ('5', '2', '9', '20'), ('9', '3', '10', '10'), ('12', '3', '10', '15'), ('3', '4', '11', '10'), ('11', '5', '7', '35'), ('4', '6', '13', '20'), ('7', '7', '12', '25'), ('8', '7', '12', '15'), ('10', '7', '12', '10'), ('6', '8', '2', '10'), ('5', '8', '2', '20'), ('1', '9', '1', '25'), ('2', '9', '1', '15'), ('4', '9', '1', '15'), ('3', '10', '9', '10'), ('8', '11', '4', '10'), ('10', '11', '4', '5'), ('12', '12', '6', '10')
\
insert into sprzedaże (klienci_id_klienta, data_sprzedaży) values ('1', '2019-12-12'), ('2', '2020-02-14'), ('3', '2020-01-02'), ('5', '2020-05-09'), ('5', '2020-08-23'), ('6', '2020-07-05'), ('7', '2020-03-20'), ('8', '2020-09-15'), ('9', '2020-12-12'), ('9', '2020-11-18'), ('9', '2020-10-21'), ('10', '2020-01-04'), ('11', '2020-09-08'), ('11', '2020-11-23'), ('11', '2020-05-12')
\
insert into towary_sprzedaże (towary_id_towaru, sprzedaże_id_sprzedaży, wspólnicy_id_wspólnika, waga_towaru) values ('2', '1', '1', '5'), ('9', '1', '1', '10'), ('5', '2', '3', '5'), ('3', '3', '2', '5'), ('7', '3', '2', '5'), ('12', '3', '2', '10'), ('10', '4', '5', '10'), ('11', '5', '10', '10'), ('6', '6', '13', '5'), ('2', '7', '12', '10'), ('1', '7', '12', '5'), ('7', '8', '4', '10'), ('1', '9', '6', '5'), ('7', '10', '5', '5'), ('3', '11', '8', '5'), ('1', '11', '8', '10'), ('4', '11', '8', '10'), ('8', '12', '10', '5'), ('9', '12', '10', '10'), ('11', '13', '4', '15'), ('11', '14', '3', '5'), ('6', '14', '3', '5'), ('7', '15', '11', '10'), ('4', '15', '11', '5'), ('3', '15', '11', '10')
\
