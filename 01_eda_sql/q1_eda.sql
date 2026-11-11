SELECT * FROM orders;

-- Total de entradas da tabela (48998)
SELECT COUNT(*) FROM orders;

--- Busca por valores nulos: inicialmente pode parecer que não existem, por isso é importante checar por NULL e valores vazios
SELECT * 
FROM orders
WHERE id IS NULL 
   OR order_number IS NULL
   OR channel IS NULL
   OR customer_id  IS NULL
   OR salesperson_id IS NULL
   OR location_id IS NULL
   OR status IS NULL
   OR subtotal IS NULL
   OR discount_amount IS NULL
   OR total IS NULL
   OR placed_at IS NULL
   OR created_at IS NULL
   OR updated_at IS NULL;

--- Testei incluindo uma coluna por vez e vi que apenas salesperson_id tem dados vazios
SELECT * 
FROM orders
WHERE id = "" 
   OR order_number = ""
   OR channel = ""
   OR customer_id  = ""
   OR salesperson_id = ""
   OR location_id = ""
   OR status = ""
   OR subtotal = ""
   OR discount_amount = ""
   OR total = ""
   OR placed_at = ""
   OR created_at = ""
   OR updated_at = "";

--- Contagem de valores nulos: verificamos que quase metade da coluna salesperson_id é vazia
SELECT COUNT(*) FROM orders WHERE salesperson_id = "";

-- Intervalo de datas analisado
SELECT MIN(created_at) AS data_inicio, MAX(created_at) AS data_fim
FROM orders;

-- Dados básicos da coluna total (mediana próxima da média indica que não há uma dispersão grande)
SELECT MIN(total) AS menor_venda, MAX(total) AS maior_venda, AVG(total) AS venda_media, MEDIAN(total) AS venda_mediana
FROM orders WHERE status IS NOT "cancelled";

-- Análise de total de vendas por faixa (vendas a partir de 70000 são incomuns, e acima de 100000 raríssimas)
SELECT 
    CASE 
        WHEN total < 10000 THEN 'Menor que R$10000'
        WHEN total >= 10000 AND total < 20000 THEN 'Entre R$10000 e R$20000'
        WHEN total >= 20000 AND total < 30000 THEN 'Entre R$20000 e R$30000'
        WHEN total >= 30000 AND total < 40000 THEN 'Entre R$30000 e R$40000'
        WHEN total >= 40000 AND total < 50000 THEN 'Entre R$40000 e R$50000'
        WHEN total >= 50000 AND total < 60000 THEN 'Entre R$50000 e R$60000'
        WHEN total >= 60000 AND total < 70000 THEN 'Entre R$60000 e R$70000'
        WHEN total >= 70000 AND total < 80000 THEN 'Entre R$70000 e R$80000'
        WHEN total >= 80000 AND total < 90000 THEN 'Entre R$80000 e R$90000'
        WHEN total >= 90000 AND total < 100000 THEN 'Entre R$90000 e R$100000'
        ELSE 'Mais que R$100000' 
    END AS PriceTier,
    COUNT(*) AS total_orders
FROM orders
WHERE status IS NOT "cancelled"
GROUP BY 
    CASE 
        WHEN total < 10000 THEN 'Menor que R$10000'
        WHEN total >= 10000 AND total < 20000 THEN 'Entre R$10000 e R$20000'
        WHEN total >= 20000 AND total < 30000 THEN 'Entre R$20000 e R$30000'
        WHEN total >= 30000 AND total < 40000 THEN 'Entre R$30000 e R$40000'
        WHEN total >= 40000 AND total < 50000 THEN 'Entre R$40000 e R$50000'
        WHEN total >= 50000 AND total < 60000 THEN 'Entre R$50000 e R$60000'
        WHEN total >= 60000 AND total < 70000 THEN 'Entre R$60000 e R$70000'
        WHEN total >= 70000 AND total < 80000 THEN 'Entre R$70000 e R$80000'
        WHEN total >= 80000 AND total < 90000 THEN 'Entre R$80000 e R$90000'
        WHEN total >= 90000 AND total < 100000 THEN 'Entre R$90000 e R$100000'
        ELSE 'Mais que R$100000'
    END;

--- Em quantos pedidos foi concedido desconto?
SELECT COUNT(*) FROM orders WHERE discount_amount > 0;

--- Total de vendas e lucro por ano
SELECT 
    STRFTIME('%Y', created_at) AS transaction_year, 
    SUM(total) AS total_amount,
    COUNT(*) AS total_orders
FROM 
    orders
WHERE 
	status IS NOT "cancelled"
GROUP BY 
    transaction_year
ORDER BY 
    transaction_year ASC;

-- Total de vendas por canal (geral)
SELECT
    channel, 
    COUNT(*) AS total_rows
FROM 
    orders
WHERE 
	status IS NOT "cancelled"
GROUP BY 
    channel;

-- Total de vendas por canal a cada ano (a empresa sempre vendeu mais pelo ecommerce)
SELECT
    STRFTIME('%Y', created_at) AS transaction_year,
    channel,
    SUM(total) AS total_amount,
    COUNT(*) AS total_orders
FROM orders
WHERE 
	status IS NOT "cancelled"
GROUP BY transaction_year, channel;

/* Hipótese: Quando o id do vendedor está ausente, a compra foi feita online?
 * Conclusão: Sim, isso é verdade em todos os casos, embora nem toda compra feita pelo ecommerce 
 * não tenha um id de vendedor. Isso me faz acreditar que a ausência do id do vendedor não é uma 
 * inconsistência, e sim uma característica real: o cliente não teve necessidade de interagir 
 * com um vendedor enquanto comprava online 
*/
SELECT 
    channel, 
    COUNT(*) AS total_rows
FROM 
    orders
WHERE
	salesperson_id = ""
GROUP BY 
    channel;

SELECT DISTINCT salesperson_id FROM orders;

