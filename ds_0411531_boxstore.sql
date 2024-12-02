/*
** Name: Damandeep Singh
** Date: 2024-09-04
** course: COMP-1701 (258748) Transforming Data Into Databases
** File Name: ds_0411531_boxstore.sql
** History: 

2024-09-17  Clean Database Block Code
            - Using compliant UTF-8 Encoding (utf8mb4/_unicode_ci)
            - DROP/CREATE/USE boxstore DATABASE syntax Block code
            
-- -------------------------------------------------------------------

2024-10-02  Clean Database Block Code
            - DROP/CREATE-TRUNCATE/INSERT/SELECT TABLE
            
-- -------------------------------------------------------------------

2024-11-04  Clean Database Block Code
            - DROP/CREATE-TRUNCATE/INSERT/SELECT geo TABLES
            - ALTER and Update query for people TABLE
            - Envelope Address Format Query

**
*/
-- -------------------------------------------------------------------
-- DROP/CREATE/USE boxstore DATABASE syntax block

USE mysql;

DROP DATABASE IF EXISTS ds_0411531_boxstore;
CREATE DATABASE IF NOT EXISTS ds_0411531_boxstore
CHARSET='utf8mb4'
COLLATE='utf8mb4_unicode_ci';

USE ds_0411531_boxstore;





-- -------------------------------------------------------------------
-- DROP/CREATE-TRUNCATE/INSERT/SELECT geo_address_type TABLE 
DROP TABLE IF EXISTS geo_address_type;

CREATE TABLE IF NOT EXISTS geo_address_type (
    addr_type_id TINYINT    AUTO_INCREMENT,    -- PK
    addr_type VARCHAR(15)   NOT NULL,         -- UK0
    active BIT              NOT NULL DEFAULT 1,          -- system
    CONSTRAINT ga_PK        PRIMARY KEY (addr_type_id),
    CONSTRAINT ga_UK_atypeA UNIQUE (addr_type ASC)
);

TRUNCATE TABLE geo_address_type;

INSERT INTO geo_address_type (addr_type)
VALUES  ('Apartment')
       ,('Building')
       ,('Condominium')
       ,('Head Office')
       ,('House')       
       ,('Mansion')
       ,('Other')
       ,('Townhouse')
       ,('Warehouse');

SELECT ga.addr_type_id, ga.addr_type, ga.active
FROM geo_address_type ga
WHERE ga.active = 1;




-- People: DROP/CREATE-TRUNCATE/INSERT/SELECT geo_country TABLE
DROP TABLE IF EXISTS geo_country;
CREATE TABLE IF NOT EXISTS geo_country (
    co_id   TINYINT             AUTO_INCREMENT
  , co_name VARCHAR(60)         NOT NULL
  , co_abbr CHAR(2)             NOT NULL
  , active  BIT                 NOT NULL DEFAULT 1
  , CONSTRAINT gco__PK          PRIMARY KEY(co_id)
  , CONSTRAINT gco__UK_name UNIQUE (co_name ASC)
  , CONSTRAINT gco__UK_abbr UNIQUE (co_abbr ASC)
);
TRUNCATE TABLE geo_country;
INSERT INTO geo_country (co_name, co_abbr)
VALUES            ('Canada','CA')
                , ('Japan','JP')
                , ('South Korea','KR')
                , ('United States of America','US');
SELECT gco.co_id, gco.co_name, gco.co_abbr
     , gco.active
FROM   geo_country gco
WHERE  gco.active=1;



-- People: DROP/CREATE-TRUNCATE/INSERT/SELECT geo_region TABLE 
DROP TABLE IF EXISTS geo_region;
CREATE TABLE IF NOT EXISTS geo_region (
    rg_id     SMALLINT    AUTO_INCREMENT
  , rg_name   VARCHAR(50) NOT NULL
  , rg_abbr   CHAR(2) 
  , co_id     TINYINT     NOT NULL
  , active    BIT         NOT NULL  DEFAULT 1
  , CONSTRAINT grg_PK PRIMARY KEY(rg_id)
  , CONSTRAINT grg_UK 
        UNIQUE (co_id ASC, rg_name DESC)
);
TRUNCATE TABLE geo_region;
INSERT INTO geo_region (rg_name, rg_abbr, co_id)
VALUES                 ('Manitoba',   'MB', 1)
                     , ('Osaka',      NULL, 2)
                     , ('Tokyo',      NULL, 2)
                     , ('Gyeonggi',   NULL, 3)
                     , ('California', NULL, 4)
                     , ('Texas',      NULL, 4)
                     , ('Washington', NULL, 4);
SELECT grg.rg_id, grg.rg_name, grg.rg_abbr, co_id
     , grg.active
FROM   geo_region grg
WHERE  grg.active=1;



-- gr JOIN to gc
SELECT grg.rg_id, grg.rg_name, grg.rg_abbr, grg.co_id
     , gco.co_id, gco.co_name, gco.co_abbr
FROM   geo_region grg
       JOIN geo_country gco ON grg.co_id=gco.co_id
;



-- People: DROP/CREATE-TRUNCATE/INSERT/SELECT geo_towncity TABLE 
DROP TABLE IF EXISTS geo_towncity;
CREATE TABLE IF NOT EXISTS geo_towncity (
    tc_id    MEDIUMINT    AUTO_INCREMENT
  , tc_name  VARCHAR(60)  NOT NULL
  , rg_id    SMALLINT     NOT NULL
  , active   BIT          NOT NULL DEFAULT 1
  , CONSTRAINT gtc_PK PRIMARY KEY(tc_id)
  , CONSTRAINT gtc_UK 
        UNIQUE (rg_id ASC, tc_name ASC)
);
TRUNCATE TABLE geo_towncity;             
INSERT INTO geo_towncity (tc_name, rg_id)
VALUES                   ('Winnipeg', 1)
                       , ('Kadoma', 2)
                       , ('Chiyoda', 3)
                       , ('Minato', 3)
                       , ('Tokyo', 3)      
                       , ('Seoul', 4)
                       , ('Suwon', 4)
                       , ('Los Altos', 5)
                       , ('Santa Clara', 5)
                       , ('Round Rock', 6)
                       , ('Redmond', 7);
SELECT gtc.tc_id, gtc.tc_name, gtc.rg_id
     , gtc.active
FROM   geo_towncity gtc
WHERE  gtc.active=1;


-- tc JOIN to gr 

SELECT gtc.tc_id, gtc.tc_name, gtc.rg_id
     , grg.rg_id, grg.rg_name, grg.rg_abbr, grg.co_id
     , gco.co_id, gco.co_name, gco.co_abbr
FROM   geo_towncity gtc
       JOIN geo_region grg ON gtc.rg_id=grg.rg_id
       JOIN geo_country gco ON grg.co_id=gco.co_id
WHERE  1=1;




-- -------------------------------------------------------------------
-- People: DROP/CREATE-TRUNCATE/INSERT/SELECT TABLE 
DROP TABLE IF EXISTS people;
CREATE TABLE IF NOT EXISTS people (
       p_id       MEDIUMINT UNSIGNED AUTO_INCREMENT
     , full_name  VARCHAR(100) NULL
     , CONSTRAINT people___PK PRIMARY KEY(p_id)
     -- , CONSTRAINT people___UK_ UNIQUE(full_name)
);


TRUNCATE TABLE people;

INSERT INTO people (full_name) VALUES ('Brad Vincelette')
                                    , ('Damandeep Singh');

                                
LOAD DATA LOCAL INFILE
'/usr/local/mysql-8.0.36-macos14-arm64/data/ds_0411531_boxstore_people_10000.csv'
INTO TABLE people
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
(full_name);


SELECT COUNT(*)
FROM   people 
WHERE  1=1
;


-- Final working SQL
SELECT p_id, full_name
FROM people
WHERE 1=1;


-- ALTER add first_name and last_name parsed from first_name
ALTER TABLE   people
    ADD COLUMN  first_name VARCHAR(40) NULL
  , ADD COLUMN  last_name  VARCHAR(40) NULL; 
  
  
UPDATE people
SET    first_name=NULL
     , last_name =NULL
WHERE  p_id IN (1,2);

UPDATE people
SET    first_name='Brad'
     , last_name ='Vincelette'
WHERE  p_id=1;

UPDATE people
SET    first_name='Damandeep'
     , last_name ='Singh'
WHERE  p_id=2;


SELECT full_name  -- cs
     , INSTR(full_name,' ')   AS pos
     , INSTR(full_name,' ')-1 AS first_name_end_pos
     , INSTR(full_name,' ')+1 AS last_name_beg_pos
FROM   people
WHERE  p_id<=2;


-- UPDATE for 10k people records
UPDATE people
SET    first_name = TRIM( MID(full_name, 1,INSTR(full_name,' ')-1))
     , last_name  = TRIM( 
                       MID(
                          full_name
                         , INSTR(full_name,' ')+1
                         , CHAR_LENGTH(full_name)-INSTR(full_name,' ')
                       )
                   )
WHERE  p_id >= 3;



SELECT p_id, full_name, first_name, last_name
FROM   people
WHERE  p_id <= 2;





-- final people (p) SELECT
SELECT p.p_id, p.first_name, p.last_name
FROM   people p
WHERE  1=1;



ALTER TABLE people 
    DROP COLUMN   full_name
  , MODIFY COLUMN first_name VARCHAR(35) NOT NULL
  , MODIFY COLUMN last_name  VARCHAR(35)
  , ADD COLUMN email_addr    VARCHAR(50)
  , ADD COLUMN password      CHAR(32)
  , ADD COLUMN phone_pri     BIGINT UNSIGNED     -- NOT NULL later switch
  , ADD COLUMN phone_sec     BIGINT UNSIGNED
  , ADD COLUMN phone_fax     BIGINT UNSIGNED
  , ADD COLUMN addr_prefix   VARCHAR(20) 
  , ADD COLUMN addr          VARCHAR(60) 
  , ADD COLUMN addr_code     VARCHAR(8) 
  , ADD COLUMN addr_info     VARCHAR(100) 
  , ADD COLUMN addr_delivery TEXT 
  , ADD COLUMN addr_type_id  TINYINT              -- FK geo_address_type
  , ADD COLUMN tc_id         MEDIUMINT UNSIGNED   -- FK geo_towncity
  , ADD COLUMN employee      BIT                NOT NULL DEFAULT 0
  , ADD COLUMN usermod       MEDIUMINT UNSIGNED NOT NULL DEFAULT 2
  , ADD COLUMN datemod       DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP
  , ADD COLUMN useract       MEDIUMINT UNSIGNED NOT NULL DEFAULT 1
  , ADD COLUMN dateact       DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP
  , ADD COLUMN active        BIT                NOT NULL DEFAULT 1
;





UPDATE people
SET   email_addr    = CONCAT(LOWER(first_name), '.', LOWER(last_name), '@boxstore.com')
    , password      = MD5('Tokyo$ecure789')  
    , phone_pri     = 12043457890
    , phone_sec     = 12042346789
    , phone_fax     = 12049876543
    , addr_prefix   = NULL
    , addr          = '2-6-1 Roppongi'
    , addr_code     = '1060032'             
    , addr_info     = 'PO Box 1234'        
    , addr_delivery = 'Knock on Outside Door'
    , addr_type_id  = (SELECT addr_type_id FROM geo_address_type WHERE addr_type = 'Mansion' LIMIT 1)
    , tc_id         = (SELECT tc_id FROM geo_towncity WHERE tc_name = 'Tokyo' LIMIT 1)
    , employee      = 1
    , usermod       = 2
    , datemod       = NOW()
WHERE p_id = 1;

UPDATE people
SET   email_addr    = CONCAT(LOWER(first_name), '.', LOWER(last_name), '@boxstore.com')
    , password      = MD5('Minato$654') 
    , phone_pri     = 12045551234
    , phone_sec     = 12045555678
    , phone_fax     = 12045558765
    , addr_prefix   = '1560'
    , addr          = '160 Princess St'
    , addr_code     = 'R3C1A5'
    , addr_info     = 'PO Box 789' 
    , addr_delivery = 'Check with concierge on main level'
    , addr_type_id  = (SELECT addr_type_id FROM geo_address_type WHERE addr_type = 'Apartment' LIMIT 1)
    , tc_id         = (SELECT tc_id FROM geo_towncity WHERE tc_name = 'Winnipeg' LIMIT 1)
    , employee      = 1
    , usermod       = 2
    , datemod       = NOW()
WHERE p_id = 2;



-- final SELET QUERY
SELECT  p.p_id
      , p.first_name, p.last_name, p.email_addr, p.password 
      
      , CONCAT('+1(', LEFT(phone_pri, 3), ')', SUBSTRING(phone_pri, 4, 3), '-', RIGHT(phone_pri, 4)) AS phone_pri
      , CONCAT('+1(', LEFT(phone_sec, 3), ')', SUBSTRING(phone_sec, 4, 3), '-', RIGHT(phone_sec, 4)) AS phone_sec
      , CONCAT('+1(', LEFT(phone_fax, 3), ')', SUBSTRING(phone_fax, 4, 3), '-', RIGHT(phone_fax, 4)) AS phone_fax
      
      , p.addr_prefix, p.addr, p.addr_code , p.addr_info, p.addr_delivery
      , p.addr_type_id 
      , p.tc_id
FROM people p
WHERE 1=1;


-- SELECT using JOIN
SELECT 
      p.p_id, p.first_name, p.last_name, p.addr_type_id, p.tc_id
    
     , ga.addr_type_id, ga.addr_type 
    
     , gtc.tc_id, gtc.tc_name, gtc.rg_id
     , grg.rg_id, grg.rg_name, grg.rg_abbr, grg.co_id
     , gco.co_id, gco.co_name, gco.co_abbr
FROM   people p
       JOIN geo_address_type ga ON p.addr_type_id = ga.addr_type_id
       JOIN geo_towncity gtc ON p.tc_id=gtc.tc_id
       JOIN geo_region grg ON gtc.rg_id=grg.rg_id
       JOIN geo_country gco ON grg.co_id=gco.co_id
WHERE 
    p.active = 1;


-- Envelope Address Format Query
SELECT p.first_name, p.last_name
    , ga.addr_type, p.addr_prefix, p.addr
    , p.addr_info 
    , gt.tc_name, grg.rg_name, gco.co_name
    , p.addr_code
    , p.addr_delivery
FROM 
    people p
JOIN 
    geo_address_type ga ON p.addr_type_id = ga.addr_type_id
JOIN 
    geo_towncity gt ON p.tc_id = gt.tc_id
JOIN 
    geo_region grg ON gt.rg_id = grg.rg_id
JOIN 
    geo_country gco ON grg.co_id = gco.co_id
WHERE 1=1;









