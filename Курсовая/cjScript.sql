-- Скрипты для БД

USE `noginsk_school_bd`;

----------------------------------------------------------------------------------------------------->
-- Контракты срок действия которых истекает сегодня(или истек)

SELECT 
    c.`contract_id`,
    CONCAT(
        cl.`client_firstname`, ' ',
        cl.`client_lastname`) AS 'name',
    cl.`client_phone`,
    c.`contract_time`
FROM `contract` c JOIN `client` cl
ON c.`contract_client_id` = cl.`client_id` AND c.`contract_time` <= CURRENT_DATE();

----------------------------------------------------------------------------------------------------->
-- Обновление статуса истекших контрактов

SET @old_contract = (SELECT `contract_id` FROM `contract`
        WHERE `contract_time` <= CURRENT_DATE());

UPDATE `contract`
SET `contract_status` = 'Закончился'
WHERE `contract_id` IN (@old_contract);

----------------------------------------------------------------------------------------------------->

-- сколько детей в каждой группе(наполняемость)

SELECT 
    g.`groups_id` AS '№ группы',
    g.`groups_age` AS 'Категория',
    COUNT(*) AS 'Количество'
FROM `groups` g JOIN `groups_residents` gr
ON g.`groups_id` = gr.`groups_residents_id_on_groups`
GROUP BY g.`groups_id`;





-- Copyright (C) 2022 Владислав Горякин
