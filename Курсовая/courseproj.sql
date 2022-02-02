/* Код развертывания базы данных(Для моего курсового проекта)
 * Copyright (C) 2022 Владислав Горякин
 */


DROP DATABASE IF EXISTS `noginsk_school_bd`;
CREATE DATABASE `noginsk_school_bd`;

USE `noginsk_school_bd`;

DROP TABLE IF EXISTS `modules`;
CREATE TABLE `modules`(
    `modules_id` SERIAL PRIMARY KEY COMMENT 'id модуля',
    `modules_name` VARCHAR(255) COMMENT 'Название модуля'
) COMMENT = 'Модули';

DROP TABLE IF EXISTS `client`;
CREATE TABLE `client`(
    `client_id` SERIAL PRIMARY KEY COMMENT 'id клиента',
    `client_firstname` VARCHAR(100) COMMENT 'Имя',
    `client_middlename` VARCHAR(100) COMMENT 'Отчество',
    `client_lastname` VARCHAR(100) COMMENT 'Фамилия',
    `client_email` VARCHAR(120) UNIQUE COMMENT 'email',
    `client_phone` BIGINT UNSIGNED COMMENT 'Номер телефона',
    `client_created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания записи',
    KEY `idx_of_last_firstname`(`client_lastname`,`client_firstname`)
) COMMENT = 'Клиенты(вкл.потенциальных)';

DROP TABLE IF EXISTS `contract`;
CREATE TABLE `contract`(
    `contract_id` SERIAL PRIMARY KEY COMMENT 'id Договора',
    `contract_client_id` BIGINT UNSIGNED NOT NULL COMMENT 'id клиента',  -- Внешний ключ
    `contract_sum` BIGINT UNSIGNED COMMENT 'Сумма',
    `contract_time` DATE COMMENT 'Срок действия',
    `contract_status` ENUM('Действует','Закончился') DEFAULT 'Действует',
    `contract_created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания записи',
    `contract_updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Дата обновления записи',
    FOREIGN KEY (`contract_client_id`) REFERENCES `client`(`client_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Договора';

DROP TABLE IF EXISTS `workers`;
CREATE TABLE `workers`(
    `workers_id` SERIAL PRIMARY KEY COMMENT 'id Работника',
    `workers_post` ENUM('Тьютор','Ассистент','Администратор') COMMENT 'Должность',
    `workers_firstname` VARCHAR(100) COMMENT 'Имя',
    `workers_middlename` VARCHAR(100) COMMENT 'Отчество',
    `workers_lastname` VARCHAR(100) COMMENT 'Фамилия',
    `workers_email` VARCHAR(120) UNIQUE COMMENT 'email',
    `workers_phone` BIGINT UNSIGNED COMMENT 'Номер телефона',
    `workers_status` ENUM('Работает','Больничный','Отпуск') DEFAULT 'Работает' COMMENT 'Статус',
    `workers_created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания записи',
    `workers_updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Дата обновления записи',
    KEY `idx_of_last_firstname`(`workers_lastname`,`workers_firstname`)
) COMMENT = 'Работники';

DROP TABLE IF EXISTS `resident`;
CREATE TABLE `resident`(
    `resident_id` SERIAL PRIMARY KEY COMMENT 'id резитента',
    `resident_firstname` VARCHAR(100) COMMENT 'Имя',
    `resident_middlename` VARCHAR(100) COMMENT 'Отчество',
    `resident_lastname` VARCHAR(100) COMMENT 'Фамилия',
    `resident_client_id` BIGINT UNSIGNED NOT NULL COMMENT 'id клиента(родителя)',  -- Внешний ключ
    FOREIGN KEY (`resident_client_id`) REFERENCES `client`(`client_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    KEY `idx_of_last_firstname`(`resident_lastname`,`resident_firstname`)
) COMMENT = 'Резиденты(дети)';

DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups`(
    `groups_id` SERIAL PRIMARY KEY COMMENT 'id группы',
    `groups_age` ENUM('Младшая', 'Средняя', 'Старшая') COMMENT 'Возрастная группа',
    `groups_worker_id` BIGINT UNSIGNED NOT NULL COMMENT 'id Работника',  -- Внешний ключ
    FOREIGN KEY (`groups_worker_id`) REFERENCES `workers`(`workers_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Группы';

DROP TABLE IF EXISTS `groups_residents`;
CREATE TABLE `groups_residents`(
    `groups_residents_id_on_groups` BIGINT UNSIGNED NOT NULL COMMENT 'id группы',  -- Внешний ключ
    `groups_residents_id_on_resident` BIGINT UNSIGNED NOT NULL COMMENT 'id Резидента',  -- Внешний ключ
    PRIMARY KEY (`groups_residents_id_on_resident`, `groups_residents_id_on_groups`),
    FOREIGN KEY (`groups_residents_id_on_groups`) REFERENCES `groups`(`groups_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`groups_residents_id_on_resident`) REFERENCES `resident`(`resident_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Резиденты группы';

DROP TABLE IF EXISTS `work_list`;
CREATE TABLE `work_list`(
    `work_list_id` SERIAL PRIMARY KEY COMMENT 'id записи',
    `work_list_date` DATE COMMENT 'Дата',
    `work_list_workers_id` BIGINT UNSIGNED NOT NULL COMMENT 'id Работника',  -- Внешний ключ
    `work_list_hour` INT UNSIGNED NOT NULL COMMENT 'Часов отработано',
    FOREIGN KEY (`work_list_workers_id`) REFERENCES `workers`(`workers_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Табель';

DROP TABLE IF EXISTS `lessons`;
CREATE TABLE `lessons`(
    `lessons_id` SERIAL PRIMARY KEY COMMENT 'id записи',
    `lessons_date` DATE COMMENT 'Дата занятия',
    `lessons_group_id` BIGINT UNSIGNED NOT NULL COMMENT 'id группы',  -- Внешний ключ
    `lessons_module_id` BIGINT UNSIGNED NOT NULL COMMENT 'id модуля',  -- Внешний ключ
    FOREIGN KEY (`lessons_group_id`) REFERENCES `groups`(`groups_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`lessons_module_id`) REFERENCES `modules`(`modules_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Занятие';

DROP TABLE IF EXISTS `class_journal`;
CREATE TABLE `class_journal`(
    `class_journal_resident_id` BIGINT UNSIGNED NOT NULL COMMENT 'id резидента',  -- Внешний ключ
    `class_journal_lesson_id` BIGINT UNSIGNED NOT NULL COMMENT 'id занятия',  -- Внешний ключ
    PRIMARY KEY (`class_journal_resident_id`, `class_journal_lesson_id`),
    FOREIGN KEY (`class_journal_resident_id`) REFERENCES `resident`(`resident_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`class_journal_lesson_id`) REFERENCES `lessons`(`lessons_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Журнал';

DROP TABLE IF EXISTS `extracurricular`;
CREATE TABLE `extracurricular`(
    `extracurricular_id` SERIAL PRIMARY KEY COMMENT 'id записи',
    `extracurricular_date` DATE COMMENT 'Дата занятия',
    `extracurricular_resident_id` BIGINT UNSIGNED NOT NULL COMMENT 'id резидента',  -- Внешний ключ
    `extracurricular_module_id` BIGINT UNSIGNED NOT NULL COMMENT 'id модуля',  -- Внешний ключ
    FOREIGN KEY (`extracurricular_resident_id`) REFERENCES `resident`(`resident_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`extracurricular_module_id`) REFERENCES `modules`(`modules_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Отработка';

-- Поащерительная валюта(внутреняя) вместо оценок
DROP TABLE IF EXISTS `valute`;
CREATE TABLE `valute`(
    `valute_resident_id` BIGINT UNSIGNED NOT NULL UNIQUE COMMENT 'id резидента',  -- Внешний ключ
    `valute_cnt` BIGINT UNSIGNED NOT NULL DEFAULT 5 COMMENT 'счет',
    `valute_date` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания записи',
    `valute_updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Дата обновления записи',
    PRIMARY KEY(`valute_resident_id`),
    FOREIGN KEY (`valute_resident_id`) REFERENCES `resident`(`resident_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Валюта';

DROP TABLE IF EXISTS `kiber_merch`;
CREATE TABLE `kiber_merch`(
    `kiber_merch_id` SERIAL PRIMARY KEY,
    `kiber_merch_name`VARCHAR(255) COMMENT 'Название товара',
    `kiber_merch_price` BIGINT COMMENT 'Цена'
) COMMENT = 'Мерч для ярмарки';

DROP TABLE IF EXISTS `sale`;
CREATE TABLE `sale`(
    `sale_id` SERIAL PRIMARY KEY,
    `sale_resident_id` BIGINT UNSIGNED NOT NULL COMMENT 'id резидента',  -- Внешний ключ
    `sale_merch_id` BIGINT UNSIGNED NOT NULL COMMENT 'id товара',  -- Внешний ключ
    `sale_date` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания записи',
    FOREIGN KEY (`sale_resident_id`) REFERENCES `resident`(`resident_id`)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (`sale_merch_id`) REFERENCES `kiber_merch`(`kiber_merch_id`)
        ON UPDATE CASCADE ON DELETE CASCADE
) COMMENT = 'Покупки на ярмарке';

DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs`(
    `logs_user` VARCHAR(100) NOT NULL COMMENT 'Пользователь бд',
    `logs_action` ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT 'Действие',
    `logs_tbl` VARCHAR(100) NOT NULL COMMENT 'Таблица',
    `logs_date` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Дата создания записи'
) ENGINE = ARCHIVE COMMENT = 'логи бд';


-- (Для логов)

DELIMITER //
DROP PROCEDURE IF EXISTS `noginsk_school_bd`.`sp_tg_insert_log`//
CREATE PROCEDURE `noginsk_school_bd`.`sp_tg_insert_log`(IN `action` VARCHAR(100), `tbl` VARCHAR(100))
BEGIN 
    DECLARE `bd_user` VARCHAR(100);
     
    SET `bd_user` = (SELECT SubString(USER(), 1, InStr(User(), '@')-1));

    INSERT INTO `logs`(`logs_user`, `logs_action`, `logs_tbl`)
    VALUES 
        (`bd_user`, `action`, `tbl`);
        
END//
DELIMITER ;

-- Вьюшки

-- Потенциальные клиенты
CREATE OR REPLACE VIEW `v_non_contract_client` AS
SELECT 
    cl.`client_id`,
    CONCAT(
        cl.`client_firstname`, ' ',
        cl.`client_lastname`) AS 'name',
    cl.`client_phone` AS 'phone',
    cl.`client_email` AS 'email'
FROM `contract` c RIGHT JOIN `client`cl
ON c.`contract_client_id` = cl.`client_id`
WHERE c.`contract_client_id` IS NULL;

-- Валюта у детей
CREATE OR REPLACE VIEW `v_valute_on_resident` AS
SELECT
    v.`valute_resident_id` AS 'id',
    CONCAT(
        r.`resident_firstname`, ' ',
        r.`resident_lastname`) AS 'name',
    v.`valute_cnt` AS 'cnt' 
FROM `resident` r JOIN `valute` v 
ON r.`resident_id` = v.`valute_resident_id`;


-- Триггеры

-- Добавление валюты за посещение
DELIMITER //
DROP TRIGGER IF EXISTS `add_valute_from_lessons`//
CREATE TRIGGER `add_valute_from_lessons`
AFTER INSERT 
ON `class_journal` FOR EACH ROW 
BEGIN 
    UPDATE `valute`
    SET `valute_cnt` = `valute_cnt` + 10
    WHERE `valute_resident_id` = NEW.`class_journal_resident_id`;
END//
DELIMITER ;
 
-- Минус от счета за покупки на ярмарке
DELIMITER //
DROP TRIGGER IF EXISTS `delete_valute_from_sale`//
CREATE TRIGGER `delete_valute_from_sale`
AFTER INSERT 
ON `sale` FOR EACH ROW 
BEGIN 
    UPDATE `valute`
    SET `valute_cnt` = `valute_cnt` - (
        SELECT `kiber_merch_price` FROM `kiber_merch`
        WHERE `kiber_merch_id` = NEW.`sale_merch_id`)
    WHERE `valute_resident_id` = NEW.`sale_resident_id`;
END//
DELIMITER ;

-- Триггеры для логов

DELIMITER //
DROP TRIGGER IF EXISTS `log_insert_on_contract`//
CREATE TRIGGER `log_insert_on_contract`
AFTER INSERT 
ON `contract` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('INSERT', 'contract');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_delete_on_contract`//
CREATE TRIGGER `log_delete_on_contract`
AFTER DELETE 
ON `contract` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('DELETE', 'contract');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_update_on_contract`//
CREATE TRIGGER `log_update_on_contract`
AFTER UPDATE 
ON `contract` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('UPDATE', 'contract');
END//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS `log_insert_on_client`//
CREATE TRIGGER `log_insert_on_client`
AFTER INSERT 
ON `client` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('INSERT', 'client');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_delete_on_client`//
CREATE TRIGGER `log_delete_on_client`
AFTER DELETE 
ON `client` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('DELETE', 'client');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_update_on_client`//
CREATE TRIGGER `log_update_on_client`
AFTER UPDATE 
ON `client` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('UPDATE', 'client');
END//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS `log_insert_on_resident`//
CREATE TRIGGER `log_insert_on_resident`
AFTER INSERT 
ON `resident` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('INSERT', 'resident');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_delete_on_resident`//
CREATE TRIGGER `log_delete_on_resident`
AFTER DELETE 
ON `resident` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('DELETE', 'resident');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_update_on_resident`//
CREATE TRIGGER `log_update_on_resident`
AFTER UPDATE 
ON `resident` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('UPDATE', 'resident');
END//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS `log_insert_on_workers`//
CREATE TRIGGER `log_insert_on_workers`
AFTER INSERT 
ON `workers` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('INSERT', 'workers');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_delete_on_workers`//
CREATE TRIGGER `log_delete_on_workers`
AFTER DELETE 
ON `workers` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('DELETE', 'workers');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_update_on_workers`//
CREATE TRIGGER `log_update_on_workers`
AFTER UPDATE 
ON `workers` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('UPDATE', 'workers');
END//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS `log_insert_on_work_list`//
CREATE TRIGGER `log_insert_on_work_list`
AFTER INSERT 
ON `work_list` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('INSERT', 'work_list');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_delete_on_work_list`//
CREATE TRIGGER `log_delete_on_work_list`
AFTER DELETE 
ON `work_list` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('DELETE', 'work_list');
END//
DELIMITER ;
-- 
DELIMITER //
DROP TRIGGER IF EXISTS `log_update_on_work_list`//
CREATE TRIGGER `log_update_on_work_list`
AFTER UPDATE 
ON `work_list` FOR EACH ROW 
BEGIN 
    CALL `sp_tg_insert_log`('UPDATE', 'work_list');
END//
DELIMITER ;


-- Хранимые процедуры

-- Добавление резидента

DELIMITER //
DROP PROCEDURE IF EXISTS  `noginsk_school_bd`.`sp_resident_add`//
CREATE DEFINER=`root`@`localhost` 
PROCEDURE `noginsk_school_bd`.`sp_resident_add`(
IN
    `firstname` VARCHAR(100), `middlename` VARCHAR(100), `lastname` VARCHAR(100), `client_id` BIGINT,
OUT  
    `tran_result` varchar(100))
BEGIN
    
    DECLARE `_rollback` BIT DEFAULT 0;
    DECLARE `code` varchar(100);
    DECLARE `error_string` varchar(100); 
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    
    BEGIN
        SET `_rollback` = 1;
        GET stacked DIAGNOSTICS CONDITION 1
            `code` = RETURNED_SQLSTATE, `error_string` = MESSAGE_TEXT;
        SET `tran_result` = concat('Ошибка: ', `code`, ' Текст ошибки: ', `error_string`);
    END;

    START TRANSACTION;

    INSERT INTO `resident`(`resident_firstname`, `resident_middlename`, `resident_lastname`, `resident_client_id`)
    VALUES (`firstname`, `middlename`, `lastname`, `client_id`);
        
    INSERT INTO `valute`(`valute_resident_id`)
    VALUES (LAST_INSERT_ID());
    
    IF `_rollback` THEN
        ROLLBACK;
    ELSE
        SET `tran_result` = 'Данные добавлены';
        COMMIT;
    END IF;
END//
DELIMITER ;


-- Расчет отработанных часов за указанный месяц и год

DELIMITER //
DROP PROCEDURE IF EXISTS  `noginsk_school_bd`.`sp_work_hour_calc`//
CREATE DEFINER=`root`@`localhost` 
PROCEDURE `noginsk_school_bd`.`sp_work_hour_calc`(IN `month_numb` INT, `years` INT)
BEGIN 
    SELECT 
        CONCAT
            (w.`workers_firstname`, ' ',
             w.`workers_middlename`, ' ',
             w.`workers_lastname`) AS 'Работник',
        SUM(wl.`work_list_hour`) AS 'часы'
    FROM `work_list` wl JOIN `workers` w
    ON w.`workers_id` = wl.`work_list_workers_id` 
    AND 
    (MONTH(wl.`work_list_date`) = `month_numb` AND YEAR(wl.`work_list_date`) = `years`)
    GROUP BY w.`workers_id`; 
END//
DELIMITER ;


-- Добавление валюты на счет ребенка

DELIMITER //
DROP PROCEDURE IF EXISTS  `noginsk_school_bd`.`sp_upd_valute`//
CREATE DEFINER=`root`@`localhost` 
PROCEDURE `noginsk_school_bd`.`sp_upd_valute`(IN `id` BIGINT, `cnt` BIGINT, OUT `tran_result` varchar(100))
BEGIN 
    DECLARE `_rollback` BIT DEFAULT 0;
    DECLARE `code` varchar(100);
    DECLARE `error_string` varchar(100); 
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    
    BEGIN
        SET `_rollback` = 1;
        GET stacked DIAGNOSTICS CONDITION 1
            `code` = RETURNED_SQLSTATE, `error_string` = MESSAGE_TEXT;
        SET `tran_result` = concat('Ошибка: ', `code`, ' Текст ошибки: ', `error_string`);
    END;

    START TRANSACTION;

        UPDATE `valute`
        SET `valute_cnt` = `valute_cnt` + `cnt`
        WHERE `valute_resident_id` = `id`;

    IF `_rollback` THEN
        ROLLBACK;
    ELSE
        SET `tran_result` = 'Данные обновлены';
        COMMIT;
    END IF;
END//
DELIMITER ;

-- Copyright (C) 2022 Владислав Горякин