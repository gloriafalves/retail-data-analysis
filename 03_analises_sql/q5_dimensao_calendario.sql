-- Criar dimensão calendário
CREATE TABLE calendar AS
WITH limits AS (
	-- Estabelecer limites com base no intervalo de datas da tabela orders
    SELECT 
        -- DATE_TRUNC zera os minutos/segundos para começar no início daquela hora
        DATE_TRUNC('hour', MIN(created_at)) AS date_inicio,
        DATE_TRUNC('hour', MAX(created_at)) AS date_fim
    FROM orders
)
SELECT
    date_hour::TIMESTAMP AS id,
    date_hour::DATE AS date,
    EXTRACT(YEAR FROM date_hour)::INT AS year,
    EXTRACT(MONTH FROM date_hour)::INT AS month,
    EXTRACT(DAY FROM date_hour)::INT AS day,
    EXTRACT(HOUR FROM date_hour)::INT AS hour,
    EXTRACT(DOW FROM date_hour)::INT AS week_day,
    TO_CHAR(date_hour, 'TMMonth') AS month_name,
    TO_CHAR(date_hour, 'TMDay') AS week_day_name
FROM limits, 
generate_series(
    limits.date_inicio, 
    limits.date_fim, 
    '1 hour'::INTERVAL
) AS t(date_hour);

-- Define a chave primária
ALTER TABLE calendar ADD PRIMARY KEY (id);

--- Mostrar datas distintas na tabela nova (2557, no total)
SELECT COUNT(DISTINCT date) FROM calendar;

-- Considerando o filtro do canal de vendas, a tabela orders fica em 2479 datas distintas
SELECT COUNT(DISTINCT orders.created_at::date) 
FROM orders 
WHERE orders.channel = 'pos';

-- Média de faturamento por dia da semana
WITH faturamento AS (
	-- Seleção das vendas feitas em lojas físicas
	SELECT 
		SUM(orders.total) AS total, 
		orders.created_at::date AS data_venda
	FROM orders
	WHERE orders.channel = 'pos'
	GROUP BY data_venda
)
SELECT 
	calendar.week_day_name,
	COALESCE(AVG(faturamento.total),0) as media_dia_semana
FROM calendar 
LEFT JOIN faturamento ON calendar.date = faturamento.data_venda
GROUP BY calendar.week_day_name
ORDER BY media_dia_semana
;
