-- Total de clientes
SELECT COUNT(*) FROM customers;

-- Faturamento total por cliente em ordem decrescente
SELECT SUM(total) as total_revenue_per_customer, customer_id 
FROM orders 
GROUP BY customer_id 
ORDER BY total_revenue_per_customer DESC;

-- Contagem total de transações associadas a cada cliente em ordem decrescente
SELECT COUNT(id) as total_transactions_per_customer, customer_id 
FROM orders 
GROUP BY customer_id 
ORDER BY total_transactions_per_customer DESC;

-- Ticket médio por cliente em ordem decrescente com desempate por customer_id
SELECT (SUM(total)/COUNT(id)) as ticket_medio, customer_id
FROM orders
GROUP BY customer_id 
ORDER BY ticket_medio DESC, customer_id ASC;

-- Total de categorias existentes no catálogo da empresa
SELECT COUNT(*) FROM categories;

-- Diversidade de categorias que cada cliente comprou em ordem crescente
SELECT customer_id, COUNT(DISTINCT categories.id) as total_categories_bought_from 
FROM orders
JOIN order_items ON orders.id = order_items.order_id
JOIN product_variants ON product_variants.id = order_items.product_variant_id
JOIN products ON products.id = product_variants.product_id
JOIN categories ON categories.id = products.category_id
GROUP BY customer_id
ORDER BY total_categories_bought_from ASC;

-- Rank do top 10 (ticket médio + filtro de categorias)
WITH customer_metrics AS (
    SELECT 
        customer_id,
        (SUM(total) / COUNT(id)) AS ticket_medio
    FROM orders
    GROUP BY customer_id
)
SELECT
	customer_metrics.ticket_medio,
    customer_metrics.customer_id,
    COUNT(DISTINCT products.category_id) AS total_categorias
FROM orders
JOIN order_items ON orders.id = order_items.order_id
JOIN product_variants ON product_variants.id = order_items.product_variant_id
JOIN products ON products.id = product_variants.product_id
JOIN customer_metrics ON customer_metrics.customer_id = orders.customer_id
GROUP BY customer_metrics.customer_id, customer_metrics.ticket_medio
HAVING COUNT(DISTINCT products.category_id) >= 13
ORDER BY customer_metrics.ticket_medio DESC, customer_metrics.customer_id ASC
LIMIT 10;

-- Categoria de produto que concentra a maior quantidade total de itens comprados
WITH customer_metrics AS (
    -- 1. Calcula Ticket Médio diretamente da tabela orders (sem risco de duplicar faturamento)
    SELECT 
        customer_id,
        SUM(total) AS faturamento_total,
        COUNT(id) AS frequencia,
        (SUM(total) / COUNT(id)) AS ticket_medio
    FROM orders
    GROUP BY customer_id
),
customer_diversity AS (
    -- 2. Calcula a diversidade de categorias cruzando com os itens
    SELECT 
        orders.customer_id,
        COUNT(DISTINCT products.category_id) AS total_categorias
    FROM orders
    JOIN order_items ON orders.id = order_items.order_id
    JOIN product_variants ON product_variants.id = order_items.product_variant_id
    JOIN products ON products.id = product_variants.product_id
    GROUP BY orders.customer_id
    HAVING COUNT(DISTINCT products.category_id) >= 13
),
top_10_faithful_customers AS (
    -- 3. Junta as métricas de ticket médio com o filtro de diversidade
    SELECT 
        customer_metrics.customer_id,
        customer_metrics.ticket_medio
    FROM customer_metrics
    JOIN customer_diversity ON customer_metrics.customer_id = customer_diversity.customer_id
    ORDER BY customer_metrics.ticket_medio DESC, customer_metrics.customer_id ASC
    LIMIT 10
)
-- 4. Identifica a categoria mais vendida para esses 10 clientes
SELECT
    categories.id AS category_id,
    categories.name AS category_name,
    SUM(order_items.quantity) AS total_itens_vendidos
FROM orders
JOIN order_items ON order_items.order_id = orders.id
JOIN product_variants ON product_variants.id = order_items.product_variant_id
JOIN products ON products.id = product_variants.product_id
JOIN categories ON categories.id = products.category_id
WHERE orders.customer_id IN (SELECT customer_id FROM top_10_faithful_customers)
GROUP BY categories.id, categories.name
ORDER BY total_itens_vendidos DESC
LIMIT 1;