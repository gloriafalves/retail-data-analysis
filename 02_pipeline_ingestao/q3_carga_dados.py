import os
import psycopg2
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine

# Configurações de diretório
DIRETORIO_CSV = './dados'
ARQUIVO_DDL = 'codigo/schema.sql'

def criar_banco(db_name):
    con = psycopg2.connect(
        host='localhost',
        database='postgres',
        user='postgres',
        password='postgres',
        port='5432'
    )

    con.autocommit = True
    cur = con.cursor()

    try:
        sql_script = f''' CREATE DATABASE {db_name}; '''
        cur.execute(sql_script)
        print(f"Database '{db_name}' created successfully.")
    except psycopg2.errors.DuplicateDatabase:
        print(f"Database '{db_name}' already exists.")
    finally:
        cur.close()
        con.close()

def criar_tabelas(db_name):
    con = psycopg2.connect(
        host='localhost',
        database=f'{db_name}',
        user='postgres',
        password='postgres',
        port='5432'
    )
    cur = con.cursor()

    try:
        with open(ARQUIVO_DDL, 'r') as file:
            sql_script = file.read()
        cur.execute(sql_script)
        con.commit()
        print("Tabelas criadas com sucesso.")
    except Exception as e:
        con.rollback()
        print(f"An error occurred: {e}")
    finally:
        cur.close()
        con.close()
    
def carregar_arquivos_csv(db_name):
    engine = create_engine(f'postgresql+psycopg2://postgres:postgres@localhost:5432/{db_name}')
    
    arquivos = [
        "attributes.csv",
        "brands.csv",
        "categories.csv",
        "customers.csv",
        "locations.csv",
        "suppliers.csv",
        "addresses.csv",
        "employees.csv",
        "orders.csv",
        "fiscal_invoices.csv",
        "payments.csv",
        "products.csv",
        "product_variants.csv",
        "order_items.csv",
        "product_suppliers.csv",
        "purchase_orders.csv",
        "purchase_order_items.csv",
        "goods_receipts.csv",
        "goods_receipt_items.csv",
        "returns.csv",
        "return_items.csv",
        "stock_levels.csv",
        "stock_movements.csv",
        "variant_attribute_values.csv"
    ]

    for file_name in arquivos:
        file_path = os.path.join(DIRETORIO_CSV, file_name)
        table_name = os.path.splitext(file_name)[0].lower()
        
        print(f"Processing '{file_name}' into table '{table_name}'...")
        try:
            df = pd.read_csv(
                file_path, 
                encoding="utf-8"
            )
            
            df.to_sql(
                name=table_name,
                con=engine,
                if_exists="append",
                index=False,
                chunksize=10000,
            )
            print(f"Successfully loaded {len(df)} rows into '{table_name}'.")

        except Exception as e:
            print(f"Error processing {file_name}: {e}")

    engine.dispose()
    print("Database connection pool closed.")
    print("All CSV files have been processed!")


if __name__ == '__main__':
    db_name = "lhnautical"
    os.makedirs(DIRETORIO_CSV, exist_ok=True)
    criar_banco(db_name)
    criar_tabelas(db_name)
    carregar_arquivos_csv(db_name)