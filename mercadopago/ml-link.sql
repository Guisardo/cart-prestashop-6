INSERT INTO `psks_request_sql` VALUES (2, 'combinaciones-stocks-all-colors', 'SELECT product.reference,\r\nproduct_lang.name AS product_name, \r\nproduct.color, SUM(CASE WHEN attribute_lang.name = \'0-1 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'0-1 M\', SUM(CASE WHEN attribute_lang.name = \'1-3 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'1-3 M\', SUM(CASE WHEN attribute_lang.name = \'3-6 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'3-6 M\', SUM(CASE WHEN attribute_lang.name = \'6-9 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'6-9 M\', SUM(CASE WHEN attribute_lang.name = \'9-12 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'9-12 M\', SUM(CASE WHEN attribute_lang.name = \'12-18 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'12-18 M\', SUM(CASE WHEN attribute_lang.name = \'18-24 M\' AND colors.color = product.color THEN product_attribute.quantity ELSE 0 END) AS \'18-24 M\'\r\nFROM (\r\nSELECT *\r\nFROM psks_product product, \r\n(\r\nSELECT DISTINCT attribute_lang.name AS color\r\nFROM psks_product_attribute_combination product_attribute_combination\r\nINNER JOIN psks_attribute_lang attribute_lang ON attribute_lang.id_attribute = product_attribute_combination.id_attribute AND attribute_lang.id_lang = 3\r\nWHERE attribute_lang.name NOT LIKE \'% M\') AS all_colors\r\nWHERE product.active = 1\r\n) AS product\r\nINNER JOIN psks_product_attribute product_attribute ON product_attribute.id_product = product.id_product\r\nINNER JOIN `psks_product_attribute_combination` product_attribute_combination ON product_attribute.id_product_attribute = product_attribute_combination.id_product_attribute\r\nINNER JOIN psks_attribute_lang attribute_lang ON attribute_lang.id_attribute = product_attribute_combination.id_attribute AND attribute_lang.id_lang =3\r\nINNER JOIN psks_product_lang product_lang ON product_lang.id_product = product.id_product AND product_lang.id_lang = 3\r\nLEFT JOIN (\r\nSELECT product.id_product, \r\nproduct_attribute_combination.id_product_attribute,\r\nattribute_lang.name AS color\r\nFROM psks_product product\r\nINNER JOIN psks_product_attribute product_attribute ON product_attribute.id_product = product.id_product\r\nINNER JOIN `psks_product_attribute_combination` product_attribute_combination ON product_attribute.id_product_attribute = product_attribute_combination.id_product_attribute\r\nINNER JOIN psks_attribute_lang attribute_lang ON attribute_lang.id_attribute = product_attribute_combination.id_attribute AND attribute_lang.id_lang =3\r\nWHERE attribute_lang.name NOT LIKE \'% M\') AS colors ON colors.id_product = product.id_product AND\r\n colors.id_product_attribute = product_attribute_combination.id_product_attribute AND\r\n colors.color = product.color AND\r\n product.active = 1\r\nGROUP BY 1, 2, 3\r\nORDER BY `id_category_default`, 1, 2, 3\r\n');
INSERT INTO `psks_request_sql` VALUES (3, 'ventas', 'SELECT invoice_date as date,\r\n    CONCAT(LTRIM(RTRIM(customer.firstname)), " ", LTRIM(RTRIM(customer.lastname))) AS name,\r\n    state.name AS state,\r\n    customer.email AS email,\r\n    payment AS price_method,\r\n    product_quantity AS quantity,\r\n    product_reference AS product_code,\r\n    REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(product_name, " - Size : ", -1), " - Talle : ", -1), " Color : ", "") AS product_type,\r\n    product_quantity * product_price AS price,\r\n    IFNULL(customer_message.message,order_message.message) AS message,\r\n    product.reference\r\nFROM psks_orders AS orders\r\nINNER JOIN psks_order_detail AS order_detail ON order_detail.id_order = orders.id_order\r\nINNER JOIN psks_product AS product ON product.id_product = order_detail.product_id\r\nINNER JOIN psks_customer AS customer ON customer.id_customer = orders.id_customer\r\nINNER JOIN psks_address AS address ON address.id_address = orders.id_address_delivery\r\nINNER JOIN psks_state AS state ON state.id_state = address.id_state\r\n\r\nLEFT JOIN (\r\nSELECT message AS message, order_message.id_order AS id_order\r\nFROM psks_customer_message\r\nINNER JOIN (\r\nSELECT MAX(id_customer_message) AS id_customer_message, customer_message.id_order AS id_order\r\nFROM psks_customer_message\r\nINNER JOIN (\r\nSELECT id_customer_thread AS id_customer_thread, last_messages_text.id_order AS id_order\r\nFROM psks_customer_message\r\nINNER JOIN (\r\nSELECT psks_message.message, psks_message.id_order FROM psks_message\r\nINNER JOIN (\r\nSELECT MAX(id_message) as id_message, id_order FROM psks_message\r\nGROUP BY id_order\r\n) AS last_messages ON last_messages.id_message = psks_message.id_message\r\n) AS last_messages_text ON last_messages_text.message = psks_customer_message.message\r\nGROUP BY psks_customer_message.id_customer_thread\r\n) AS customer_message ON customer_message.id_customer_thread = psks_customer_message.id_customer_thread\r\nGROUP BY psks_customer_message.id_customer_thread\r\n) AS order_message ON order_message.id_customer_message = psks_customer_message.id_customer_message\r\n) AS order_message ON order_message.id_order = orders.id_order\r\n\r\nLEFT JOIN (\r\nSELECT customer_message.message, max_customer_message.id_order\r\nFROM psks_customer_message AS customer_message\r\nINNER JOIN (\r\nSELECT MAX(customer_message.id_customer_message) as max_id_customer_message, customer_thread.id_order\r\nFROM psks_customer_thread AS customer_thread\r\nINNER JOIN psks_customer_message AS customer_message ON customer_message.id_customer_thread = customer_thread.id_customer_thread\r\nGROUP BY customer_thread.id_order\r\n) AS max_customer_message ON max_customer_message.max_id_customer_message = customer_message.id_customer_message\r\n) AS customer_message ON customer_message.id_order = orders.id_order\r\n\r\nWHERE orders.date_upd >= \'1900-01-01\'\r\nAND orders.current_state NOT IN (\r\n3,\r\n6,\r\n33,\r\n34\r\n)\r\nGROUP BY id_order_detail\r\nORDER BY orders.date_upd\r\n');
INSERT INTO `psks_request_sql` VALUES (4, 'combinaciones-stocks', 'SELECT product.reference,\r\nproduct_lang.name AS product_name,\r\ncolors.color,\r\nSUM(CASE WHEN attribute_lang.name = \'0-1 M\' THEN \r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'0-1 M\',\r\nSUM(CASE WHEN attribute_lang.name = \'1-3 M\' THEN\r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'1-3 M\',\r\nSUM(CASE WHEN attribute_lang.name = \'3-6 M\' THEN\r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'3-6 M\',\r\nSUM(CASE WHEN attribute_lang.name = \'6-9 M\' THEN\r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'6-9 M\',\r\nSUM(CASE WHEN attribute_lang.name = \'9-12 M\' THEN\r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'9-12 M\',\r\nSUM(CASE WHEN attribute_lang.name = \'12-18 M\' THEN\r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'12-18 M\',\r\nSUM(CASE WHEN attribute_lang.name = \'18-24 M\' THEN\r\nCASE WHEN isSet.id_product is null THEN\r\n ordered_products.usable_quantity + ordered_products.quantity_reserved_delta\r\nELSE\r\n stock_available.quantity\r\nEND \r\n  ELSE 0 END\r\n) AS \'18-24 M\'\r\nFROM psks_product AS product\r\nINNER JOIN psks_product_attribute product_attribute ON product_attribute.id_product = product.id_product\r\nINNER JOIN `psks_product_attribute_combination` product_attribute_combination ON product_attribute.id_product_attribute = product_attribute_combination.id_product_attribute\r\nINNER JOIN psks_attribute_lang attribute_lang ON attribute_lang.id_attribute = product_attribute_combination.id_attribute AND attribute_lang.id_lang =2\r\nINNER JOIN psks_product_lang product_lang ON product_lang.id_product = product.id_product AND product_lang.id_lang = 2\r\nINNER JOIN psks_stock_available stock_available ON stock_available.id_product = product.id_product AND stock_available.id_product_attribute = product_attribute_combination.id_product_attribute\r\n\r\nLEFT JOIN (\r\nselect psks_stock.id_product_attribute, psks_stock.reference, psks_stock.physical_quantity, psks_stock.usable_quantity\r\n, ifnull(-sum(product_quantity) + sum(product_quantity_refunded),0) as quantity_reserved_delta\r\n from psks_stock\r\nleft join (\r\n\r\nSELECT psks_orders.id_order, psks_order_detail.id_order_detail, psks_orders.current_state, psks_order_detail.product_attribute_id, psks_order_detail.product_quantity, psks_order_detail.product_quantity_refunded\r\nFROM psks_order_detail\r\n\r\nINNER JOIN psks_orders ON psks_orders.id_order = psks_order_detail.id_order\r\nINNER JOIN psks_order_history ON psks_order_history.id_order = psks_orders.id_order and psks_order_history.id_order_state = psks_orders.current_state\r\nINNER JOIN psks_order_state ON psks_order_state.id_order_state = psks_order_history.id_order_state\r\n\r\nWHERE psks_order_detail.id_warehouse = 1 AND \r\n((psks_orders.current_state != 8 AND psks_orders.current_state != 6) OR psks_orders.valid = 1) AND \r\npsks_order_state.shipped != 1\r\ngroup by 2\r\n\r\n\r\n) as orders on psks_stock.id_product_attribute = orders.product_attribute_id\r\ngroup by 1, 2, 3, 4\r\n) as ordered_products ON ordered_products.id_product_attribute = product_attribute.id_product_attribute\r\n\r\nINNER JOIN (\r\nSELECT product.id_product, \r\nproduct_attribute_combination.id_product_attribute,\r\nattribute_lang.name AS color\r\nFROM psks_product product\r\nINNER JOIN psks_product_attribute product_attribute ON product_attribute.id_product = product.id_product\r\nINNER JOIN `psks_product_attribute_combination` product_attribute_combination ON product_attribute.id_product_attribute = product_attribute_combination.id_product_attribute\r\nINNER JOIN psks_attribute_lang attribute_lang ON attribute_lang.id_attribute = product_attribute_combination.id_attribute AND attribute_lang.id_lang =2\r\nWHERE attribute_lang.name NOT LIKE \'% M\') AS colors ON colors.id_product = product.id_product AND\r\n colors.id_product_attribute = product_attribute_combination.id_product_attribute\r\n\r\nLEFt JOIN (\r\nselect psks_stock_available.id_product from psks_stock_available\r\ninner join psks_product on psks_product.id_product = psks_stock_available.id_product and psks_product.active = 1\r\nwhere psks_stock_available.id_product_attribute = 0 and psks_stock_available.depends_on_stock = 0\r\n) AS isSet ON isSet.id_product = product.id_product\r\n\r\nWHERE product.active = 1\r\nGROUP BY 1, 2, 3\r\nORDER BY `id_category_default`, 1, 2, 3\r\n');
INSERT INTO `psks_request_sql` VALUES (5, 'reservas', 'SELECT invoice_date as date,\r\n    CONCAT(LTRIM(RTRIM(customer.firstname)), " ", LTRIM(RTRIM(customer.lastname))) AS name,\r\n    state.name AS state,\r\n    customer.email AS email,\r\n    payment AS price_method,\r\n    product_quantity AS quantity,\r\n    product_reference AS product_code,\r\n    REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(product_name, " - Size : ", -1), " - Talle : ", -1), " Color : ", "") AS product_type,\r\n    REPLACE(product_quantity * product_price, ".", ",") AS price,\r\n    IFNULL(customer_message.message,order_message.message) AS message\r\nFROM psks_orders AS orders\r\nINNER JOIN psks_order_detail AS order_detail ON order_detail.id_order = orders.id_order\r\nINNER JOIN psks_customer AS customer ON customer.id_customer = orders.id_customer\r\nINNER JOIN psks_address AS address ON address.id_address = orders.id_address_delivery\r\nINNER JOIN psks_state AS state ON state.id_state = address.id_state\r\n\r\nLEFT JOIN (\r\nSELECT message AS message, order_message.id_order AS id_order\r\nFROM psks_customer_message\r\nINNER JOIN (\r\nSELECT MAX(id_customer_message) AS id_customer_message, customer_message.id_order AS id_order\r\nFROM psks_customer_message\r\nINNER JOIN (\r\nSELECT id_customer_thread AS id_customer_thread, last_messages_text.id_order AS id_order\r\nFROM psks_customer_message\r\nINNER JOIN (\r\nSELECT psks_message.message, psks_message.id_order FROM psks_message\r\nINNER JOIN (\r\nSELECT MAX(id_message) as id_message, id_order FROM psks_message\r\nGROUP BY id_order\r\n) AS last_messages ON last_messages.id_message = psks_message.id_message\r\n) AS last_messages_text ON last_messages_text.message = psks_customer_message.message\r\nGROUP BY psks_customer_message.id_customer_thread\r\n) AS customer_message ON customer_message.id_customer_thread = psks_customer_message.id_customer_thread\r\nGROUP BY psks_customer_message.id_customer_thread\r\n) AS order_message ON order_message.id_customer_message = psks_customer_message.id_customer_message\r\n) AS order_message ON order_message.id_order = orders.id_order\r\n\r\nLEFT JOIN (\r\nSELECT customer_message.message, max_customer_message.id_order\r\nFROM psks_customer_message AS customer_message\r\nINNER JOIN (\r\nSELECT MAX(customer_message.id_customer_message) as max_id_customer_message, customer_thread.id_order\r\nFROM psks_customer_thread AS customer_thread\r\nINNER JOIN psks_customer_message AS customer_message ON customer_message.id_customer_thread = customer_thread.id_customer_thread\r\nGROUP BY customer_thread.id_order\r\n) AS max_customer_message ON max_customer_message.max_id_customer_message = customer_message.id_customer_message\r\n) AS customer_message ON customer_message.id_order = orders.id_order\r\n\r\nWHERE orders.current_state in (\r\n9,\r\n12,\r\n13,\r\n26,\r\n29,\r\n37,\r\n38,\r\n34,\r\n33,\r\n40,\r\n42\r\n)\r\nGROUP BY id_order_detail\r\nORDER BY invoice_date\r\n');

CREATE VIEW `vw_packs` AS select 'MLA629561085' AS `container_ref`,'MLA651644908,MLA625023071' AS `content_ref`;



CREATE PROCEDURE `ps_update_packstock`(IN `pack_reference` VARCHAR(15))
    LANGUAGE SQL
    NOT DETERMINISTIC
    MODIFIES SQL DATA
    SQL SECURITY DEFINER
    COMMENT ''
BEGIN

SELECT container_ref INTO @isPack FROM vw_packs WHERE container_ref = pack_reference;

IF @isPack != pack_reference THEN
CREATE TEMPORARY TABLE IF NOT EXISTS pack_content AS (
SELECT t.container_ref container_ref, SUBSTRING_INDEX(SUBSTRING_INDEX(t.content_ref, ',', n.n), ',', -1) content_ref
  FROM vw_packs t CROSS JOIN (
   SELECT a.N + b.N * 10 + 1 n
     FROM
    (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
   ,(SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    ORDER BY n
) n
 WHERE n.n <= 1 + (LENGTH(t.content_ref) - LENGTH(REPLACE(t.content_ref, ',', '')))
 ORDER BY content_ref
);

UPDATE psks_stock_available AS sa
INNER JOIN psks_product pr ON pr.id_product = sa.id_product
SET sa.quantity = 0
where pr.reference = pack_reference;

UPDATE psks_stock_available AS sa
INNER JOIN (
select psks_product.id_product, psks_stock_available.id_product_attribute AS id_product_attribute, group_concat(psks_product_attribute_combination.id_attribute) AS ids_attributes
from psks_stock_available
INNER JOIN psks_product ON psks_product.id_product = psks_stock_available.id_product
INNER JOIN psks_product_attribute_combination ON psks_product_attribute_combination.id_product_attribute = psks_stock_available.id_product_attribute
where psks_product.reference = pack_reference
group by 1, 2
) AS container ON container.id_product = sa.id_product AND container.id_product_attribute = sa.id_product_attribute
INNER JOIN (
select ids_attributes, min(allcomb.usable_quantity) AS quantity
from (

select psks_product_attribute_combination.id_product_attribute AS id_product_attribute, group_concat(psks_product_attribute_combination.id_attribute) AS ids_attributes, (psks_stock.usable_quantity + ordered_products.quantity_reserved_delta) AS usable_quantity
from psks_stock
INNER JOIN psks_product ON psks_product.id_product = psks_stock.id_product
INNER JOIN psks_product_attribute_combination ON psks_product_attribute_combination.id_product_attribute = psks_stock.id_product_attribute
LEFT JOIN (
select psks_stock.id_product_attribute, psks_stock.reference, psks_stock.physical_quantity, psks_stock.usable_quantity
, ifnull(-sum(product_quantity) + sum(product_quantity_refunded),0) as quantity_reserved_delta
 from psks_stock
left join (

SELECT psks_orders.id_order, psks_order_detail.id_order_detail, psks_orders.current_state, psks_order_detail.product_attribute_id, psks_order_detail.product_quantity, psks_order_detail.product_quantity_refunded
FROM psks_order_detail

INNER JOIN psks_orders ON psks_orders.id_order = psks_order_detail.id_order
INNER JOIN psks_order_history ON psks_order_history.id_order = psks_orders.id_order and psks_order_history.id_order_state = psks_orders.current_state
INNER JOIN psks_order_state ON psks_order_state.id_order_state = psks_order_history.id_order_state

WHERE psks_order_detail.id_warehouse = 1 AND
((psks_orders.current_state != 8 AND psks_orders.current_state != 6) OR psks_orders.valid = 1) AND
psks_order_state.shipped != 1
group by 2

) as orders on psks_stock.id_product_attribute = orders.product_attribute_id
group by 1, 2, 3, 4
) as ordered_products ON ordered_products.id_product_attribute = psks_product_attribute_combination.id_product_attribute



where psks_product.reference in (
select content_ref from pack_content where container_ref = pack_reference
)
group by 1

) AS allcomb
group by  ids_attributes
) AS components ON components.ids_attributes = container.ids_attributes
set sa.quantity = components.quantity;

UPDATE psks_stock_available AS sa
INNER JOIN (
select psks_product.id_product, sum(psks_stock_available.quantity) AS quantity
from psks_stock_available
INNER JOIN psks_product ON psks_product.id_product = psks_stock_available.id_product
where psks_product.reference = pack_reference
AND psks_stock_available.id_product_attribute <> 0
group by 1
) AS container ON container.id_product = sa.id_product
SET sa.quantity = container.quantity
where sa.id_product_attribute = 0;
END IF;

END



CREATE FUNCTION `ps_packcontent_updated`(`id_product` INT)
    RETURNS int(11)
    LANGUAGE SQL
    NOT DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY DEFINER
    COMMENT ''
BEGIN
DECLARE CONTINUE HANDLER FOR NOT FOUND SET @isPack = NULL;

CREATE TEMPORARY TABLE IF NOT EXISTS pack_content AS (
SELECT t.container_ref container_ref, SUBSTRING_INDEX(SUBSTRING_INDEX(t.content_ref, ',', n.n), ',', -1) content_ref
  FROM vw_packs t CROSS JOIN (
   SELECT a.N + b.N * 10 + 1 n
     FROM
    (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
   ,(SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    ORDER BY n
) n
 WHERE n.n <= 1 + (LENGTH(t.content_ref) - LENGTH(REPLACE(t.content_ref, ',', '')))
 ORDER BY content_ref
);

SELECT container_ref INTO @isPack
FROM pack_content
INNER JOIN psks_product ON psks_product.reference = pack_content.content_ref
WHERE psks_product.id_product = id_product;

SET @id_pack = NULL;
IF @isPack IS NOT NULL THEN
    CALL ps_update_packstock(@isPack);
    SELECT psks_product.id_product INTO @id_pack FROM psks_product WHERE psks_product.reference = @isPack;
END IF;
RETURN @id_pack;

END