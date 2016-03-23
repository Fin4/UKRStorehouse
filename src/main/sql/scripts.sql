DROP SCHEMA IF EXISTS ukrstorehouse;
CREATE SCHEMA ukrstorehouse;

USE ukrstorehouse;

CREATE TABLE store (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL ,
  address VARCHAR(200) NOT NULL ,
  phone_number VARCHAR(20) NOT NULL ,
  max_items INT NOT NULL
);

CREATE TABLE company(
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL ,
  contract_num VARCHAR(20) NOT NULL ,
  contact_person VARCHAR(50) NOT NULL ,
  phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE item_type(
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  type VARCHAR(50) NOT NULL
);

CREATE TABLE item(
  id BIGINT PRIMARY KEY AUTO_INCREMENT ,
  type_id BIGINT NOT NULL ,
  model VARCHAR(100) NOT NULL ,
  characteristic VARCHAR(200),
  FOREIGN KEY (type_id) REFERENCES item_type(id)
);

CREATE TABLE store_item_company(
  store_id BIGINT NOT NULL ,
  item_id BIGINT NOT NULL ,
  company_id BIGINT NOT NULL ,
  num_of_items INT NOT NULL DEFAULT 0,
  CONSTRAINT PRIMARY KEY (store_id, item_id, company_id),
  FOREIGN KEY (store_id) REFERENCES store(id) ,
  FOREIGN KEY (item_id) REFERENCES item(id) ,
  FOREIGN KEY (company_id) REFERENCES company(id)
);


CREATE TRIGGER isStoreFreeUpdate
  BEFORE UPDATE ON store_item_company
  FOR EACH ROW
  BEGIN
    DECLARE free_space INTEGER;

    SELECT (max_items - sum(store_item_company.num_of_items)) INTO free_space
    FROM store INNER JOIN store_item_company ON store.id = store_item_company.store_id
      WHERE store_id = new.store_id;

    IF (free_space - (new.num_of_items - old.num_of_items)) < 0 THEN
      signal sqlstate '45000';
    END IF;
  END;

CREATE TRIGGER isStoreFreeInsert
BEFORE INSERT ON store_item_company
FOR EACH ROW
  BEGIN
    DECLARE free_space INTEGER;

    SELECT (max_items - sum(store_item_company.num_of_items)) INTO free_space
    FROM store INNER JOIN store_item_company ON store.id = store_item_company.store_id
    WHERE store_id = new.store_id;

    IF free_space - new.num_of_items < 0 THEN
      signal sqlstate '45000';
    END IF;
  END;

INSERT INTO store (name, address, phone_number, max_items)
VALUES ('Brovary', 'Кооперативная улица, 9, Украина, Киевская область, Бровары', '0632100000', 1000);

INSERT INTO store (name, address, phone_number, max_items)
VALUES ('Kiev 1', 'улица Николая Закревского, 12, Украина, Киев', '0632101111', 2000);

INSERT INTO store (name, address, phone_number, max_items)
VALUES ('Kiev 2', 'проспект Героев Сталинграда, 12, Украина, Киев', '0632102222', 500);


INSERT INTO company (name, contact_person, phone_number, contract_num)
VALUES ('Everest', 'Иванов Петр Сергеевич', '0630001111', '1112AV');

INSERT INTO company (name, contact_person, phone_number, contract_num)
VALUES ('DiaWest', 'Сидоров Иван Сергеевич', '0630002222', '1212TT');

INSERT INTO company (name, contact_person, phone_number, contract_num)
VALUES ('GigaByte', 'Петров Сергей Сергеевич', '0630003333', '9112XZ');

INSERT INTO company (name, contact_person, phone_number, contract_num)
VALUES ('CityCom', 'Кузнецов Виталий Иванович', '0630004444', '1101WY');


INSERT INTO item_type (type) VALUE ('HDD');
INSERT INTO item_type (type) VALUE ('Memory');
INSERT INTO item_type (type) VALUE ('CPU');
INSERT INTO item_type (type) VALUE ('GPU');


INSERT INTO item (type_id, model, characteristic) VALUES (1, 'Seagate ST100DM003', 'SATA 100GB');
INSERT INTO item (type_id, model, characteristic) VALUES (2, 'Kingston HX421C14FB/8', '8 GB');
INSERT INTO item (type_id, model, characteristic) VALUES (3, 'Intel Core i7-4790K BX80646I74790K ', '4x4.0GHz');
INSERT INTO item (type_id, model, characteristic) VALUES (4, 'MSI GeForce GTX 970 GAMING 4G', '1140GHz');
INSERT INTO item (type_id, model, characteristic) VALUES (4, 'ASUS STRIX-GTX970-DC2OC-4GD5', '1253GHz');
INSERT INTO item (type_id, model, characteristic) VALUES (3, 'AMD FX-6300 FD6300WMHKBOX', '6x3.5GHz');
INSERT INTO item (type_id, model, characteristic) VALUES (1, 'WD WD10EZRX', 'SATA 500Gb');



INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (1, 1, 1, 300);
INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (1, 2, 1, 500);

INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (2, 3, 1, 100);
INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (2, 4, 1, 1000);
INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (2, 5, 2, 900);

INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (3, 6, 2, 200);
INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (3, 3, 4, 100);
INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (3, 7, 4, 50);
INSERT INTO store_item_company (store_id, item_id, company_id, num_of_items) VALUES (3, 1, 4, 50);



SELECT store.name AS store_name,
  item_type.type AS item_type,
  item.model,
  item.characteristic,
  store_item_company.num_of_items,
  company.name AS company,
  company.contract_num,
  company.contact_person
FROM item_type INNER JOIN item ON item_type.id = item.type_id
INNER JOIN store_item_company ON item.id = store_item_company.item_id
INNER JOIN store ON store_item_company.store_id = store.id
INNER JOIN company ON store_item_company.company_id = company.id
ORDER BY store.name;

SELECT company.name AS company, sum(store_item_company.num_of_items) AS Total_items
FROM company INNER JOIN store_item_company ON company.id = store_item_company.company_id
GROUP BY company.name;

SELECT store.name, store.address, store.phone_number, store.max_items AS max_items,
  sum(store_item_company.num_of_items) AS current_item_count,
  (max_items - sum(store_item_company.num_of_items)) AS free_space
FROM store INNER JOIN store_item_company ON store.id = store_item_company.store_id
GROUP BY store.name;

