# Retail Data Analysis: End-to-End Analytics & Data Science Pipeline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-blue.svg)](https://www.postgresql.org/)

Pipeline de dados end-to-end desenvolvido como estudo de caso prático para o setor de varejo náutico: ingestão dinâmica de dados e modelagem relacional em PostgreSQL, análises avançadas em SQL, inteligência preditiva em Python (médias móveis e sistema de recomendação) e dashboard executivo no Power BI.

## 📌 Visão Geral da Arquitetura

O projeto resolve um problema end-to-end de negócios a partir de arquivos brutos (CSVs de ERP), cobrindo todas as etapas do ciclo de dados:

1. **Exploração & Qualidade dos Dados (EDA):** Diagnóstico inicial da base de pedidos.
2. **Engenharia de Ingestão:** DDL gerado via Python puro, modelagem relacional em PostgreSQL, tratamento de FKs polimórficas e carga automatizada.
3. **Análises de Negócio em SQL:** Segmentação avançada de clientes (clientes fiéis) e criação de dimensão de datas para correção de viés de amostragem.
4. **Data Science & Machine Learning:** Modelo baseline de previsão de demanda por médias móveis e motor de recomendação baseado em similaridade de cosseno.
5. **Business Intelligence:** Dashboard executivo interativo focado em apoio à tomada de decisão.

---

## 🗺️ Mapeamento do Desafio e Estrutura

| Etapa / Módulo | Descrição do Problema de Negócio | Stack / Ferramentas | Diretório no Repositório |
| :--- | :--- | :--- | :--- |
| **Q1. EDA Inicial** | Diagnóstico de volume, qualidade e confiabilidade da tabela de vendas (`orders`). | SQL (SQLite / DBeaver) | [`01_eda_sql/`](./01_eda_sql/) |
| **Q2. Inferência de Schema** | Geração dinâmica do arquivo `schema.sql` usando apenas bibliotecas nativas do Python. | Python 3 (Pure) | [`02_pipeline_ingestao/q2_inferencia_schema.py`](./02_pipeline_ingestao/q2_inferencia_schema.py) |
| **Q3. Carga de Dados** | Ingestão robusta de 24 tabelas CSV no banco PostgreSQL preservando integridade. | Python, SQLAlchemy, Pandas | [`02_pipeline_ingestao/q3_carga_dados.py`](./02_pipeline_ingestao/q3_carga_dados.py) |
| **Q4. Análise de Clientes** | Identificação dos "Clientes Fiéis" (alto ticket médio + diversidade >= 13 categorias). | PostgreSQL (CTEs, Window Functions) | [`03_analises_sql/q4_analise_clientes.sql`](./03_analises_sql/q4_analise_clientes.sql) |
| **Q5. Dimensão Calendário** | Correção do viés estatístico de dias sem venda via dimensão de datas em SQL. | PostgreSQL (Generate Series, Left Join) | [`03_analises_sql/q5_dimensao_calendario.sql`](./03_analises_sql/q5_dimensao_calendario.sql) |
| **Q6. Previsão de Demanda** | Modelo de previsão de demanda (Média Móvel de 3 meses) para controle de estoque. | Python, Pandas, Jupyter Notebook | [`04_data_science/q6_previsao_demanda.ipynb`](./04_data_science/q6_previsao_demanda.ipynb) |
| **Q7. Recomendação** | Algoritmo de filtragem colaborativa item-item via Similaridade de Cosseno. | Python, Scikit-Learn, NumPy | [`04_data_science/q7_sistema_recomendacao.ipynb`](./04_data_science/q7_sistema_recomendacao.ipynb) |
| **Q8. Dashboard Executivo** | Painel executivo de acompanhamento de vendas, metas e comportamento do cliente. | Power BI | [`05_dashboard/`](./05_dashboard/) |
