import os
import csv
import re
from typing import Dict, List, Set, Optional
from pathlib import Path
from datetime import datetime

# Configurações de diretório
DIRETORIO_CSV = './dados'
ARQUIVO_SAIDA_SQL = './schema.sql'

def limpar_nome(nome):
    """Remove espaços e caracteres especiais para nomes válidos em SQL."""
    nome_limpo = "".join(c if c.isalnum() else "_" for c in nome).strip("_")
    # Garante que não comece com números
    if nome_limpo and nome_limpo[0].isdigit():
        nome_limpo = f"col_{nome_limpo}"
    return nome_limpo if nome_limpo else "coluna_invalida"

def inferir_tipo_valor(valor):
    """Detecta o tipo de dado de uma única string."""
    valor = valor.strip()
    if not valor:
        return 'null'
        
    # 1. Checa Booleano
    if valor.lower() in ['true', 'false', 'boolean_true', 'boolean_false']:
        return 'boolean'
    
    # 2. Checa Inteiro
    if re.match(r'^[-+]?\d+$', valor):
        return 'integer'
    
    # 3. Checa Decimal/Float
    if re.match(r'^[-+]?\d*\.\d+$', valor) or re.match(r'^[-+]?\d+,\d+$', valor):
        return 'real'
    
    # 4. Checa Datas comuns (AAAA-MM-DD ou DD/MM/AAAA)
    Formatos_data = ['%Y-%m-%d', '%d/%m/%Y', '%Y-%m-%d %H:%M:%S', '%d/%m/%Y %H:%M:%S']
    for formato in Formatos_data:
        try:
            datetime.strptime(valor, formato)
            return 'timestamp' if ':%M' in formato else 'date'
        except ValueError:
            continue
            
    # 5. Padrão se nada acima coincidir
    return 'text'

def combinar_tipos(tipo_atual, novo_tipo):
    """Regras de precedência para quando uma coluna tem dados mistos."""
    if tipo_atual == 'null': return novo_tipo
    if novo_tipo == 'null': return tipo_atual
    if tipo_atual == 'text' or novo_tipo == 'text': return 'text'
    if tipo_atual == 'real' and novo_tipo == 'integer': return 'real'
    if tipo_atual == 'integer' and novo_tipo == 'real': return 'real'
    if tipo_atual != novo_tipo: return 'text' # Tipos conflitantes viram Texto
    return tipo_atual

def analisar_tipos_csv(caminho_arquivo, limite_linhas=100):
    """Lê o cabeçalho e analisa as primeiras linhas para inferir os tipos."""
    with open(caminho_arquivo, 'r', encoding='utf-8', errors='ignore') as f:
        leitor = csv.reader(f)
        cabecalho = next(leitor, None)
        
        if not cabecalho:
            return None, None
            
        # Inicializa todas as colunas identificadas como null/vazias
        tipos_colunas = ['null'] * len(cabecalho)
        
        # Analisa até 'limite_linhas' para descobrir os tipos reais
        for i, linha in enumerate(leitor):
            if i >= limite_linhas:
                break
            for idx, valor in enumerate(linha):
                if idx < len(tipos_colunas):
                    tipo_detectado = inferir_tipo_valor(valor)
                    tipos_colunas[idx] = combinar_tipos(tipos_colunas[idx], tipo_detectado)
                    
        # Substitui colunas que ficaram estritamente vazias por text
        tipos_colunas = [t if t != 'null' else 'text' for t in tipos_colunas]
        
        return cabecalho, tipos_colunas

# Mapeamento para garantir que valores extensos ou que não são IDs serão classificados como text
FAKE_INTEGER_MAP = [
    "tax_id",
    "phone",
    "cpf",
    "nfe_access_key",
    "series",
    "ncm_code",
    "barcode_ean"]

def gerar_sql_com_tipos(origem_dir, destino_sql):
    caminho_dir = Path(origem_dir)
    arquivos_csv = list(caminho_dir.glob('*.csv'))
    
    if not arquivos_csv:
        print("Nenhum arquivo CSV encontrado no diretório dados.")
        return

    with open(destino_sql, 'w', encoding='utf-8') as f_sql:
        f_sql.write("-- Esquema SQL gerado automaticamente com inferência de tipos\n\n")
        
        for arquivo in arquivos_csv:
            nome_tabela = limpar_nome(arquivo.stem)
            cabecalho, tipos = analisar_tipos_csv(arquivo)
            
            if not cabecalho:
                continue

            colunas_sql = []
            for coluna, tipo in zip(cabecalho, tipos):
                nome_coluna = limpar_nome(coluna)
                if nome_coluna in FAKE_INTEGER_MAP:
                    colunas_sql.append(f"    {nome_coluna} text")
                else:
                    colunas_sql.append(f"    {nome_coluna} {tipo}")

            is_pk_composite = True
            if "id" in cabecalho:
                colunas_sql[0] = f"    id SERIAL PRIMARY KEY"
                is_pk_composite = False
            else:
                # Se chave primária for composta, detectamos quais colunas fazem parte da pk
                chave_composta = []
                for i in cabecalho:
                    if "_id" in i:
                        chave_composta.append(i)

            f_sql.write(f"CREATE TABLE IF NOT EXISTS {nome_tabela} (\n")
            f_sql.write(",\n".join(colunas_sql))
            if is_pk_composite:
                f_sql.write(f",\n\tCONSTRAINT pk_{nome_tabela} PRIMARY KEY ({", ".join(chave_composta)})")
            f_sql.write("\n);\n\n")
            
    print(f"Arquivo SQL gerado com sucesso em: {destino_sql}")

# Mapeamento semântico explícito para papéis que não seguem o nome direto da tabela
ROLE_TO_TABLE_MAP = {
    "salesperson": "employees",
    "buyer": "customers",
    "received_by_employee": "employees",
    "received_by": "employees",
    "employee": "employees",
    "exchange_variant": "product_variants",
    "primary_location": "locations",
    "destination_location": "locations",
    "received_at_location": "locations"
}

def get_plural_candidates(singular_word: str) -> List[str]:
    """
    Gera as formas no plural de uma palavra em inglês seguindo regras gramaticais.
    Exemplos:
      - category -> categories (-y precedido de consoante vira -ies)
      - address  -> addresses  (terminados em -s, -x, -z, -ch, -sh ganham -es)
      - product  -> products   (regra padrão +s)
    """
    candidates = []
    
    # Regra 1: Termina em 'y' precedido por consoante (ex: category -> categories)
    if len(singular_word) > 1 and singular_word.endswith("y") and singular_word[-2] not in "aeiou":
        candidates.append(singular_word[:-1] + "ies")
        
    # Regra 2: Termina em s, x, z, ch, sh (ex: address -> addresses)
    elif singular_word.endswith(("s", "x", "z", "ch", "sh")):
        candidates.append(singular_word + "es")
        
    # Regra 3: Plural padrão (+s)
    candidates.append(singular_word + "s")
    
    return candidates


def parse_sql_schema(schema_content: str) -> Dict[str, Dict[str, str]]:
    """
    Analisa o conteúdo do arquivo schema.sql e extrai a estrutura de tabelas e colunas.
    """
    tables: Dict[str, Dict[str, str]] = {}
    
    # Expressão regular para capturar os blocos CREATE TABLE
    create_table_regex = re.compile(
        r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_]+)\s*\((.*?)\);",
        re.DOTALL | re.IGNORECASE
    )

    for match in create_table_regex.finditer(schema_content):
        table_name = match.group(1).lower()
        body = match.group(2)
        
        columns: Dict[str, str] = {}
        lines = body.split("\n")
        
        for line in lines:
            line = line.strip()
            
            # Ignora linhas vazias, comentários ou constraints no nível de tabela
            if not line or line.startswith("--") or line.startswith("/*"):
                continue
            if line.upper().startswith(("PRIMARY KEY", "CONSTRAINT", "FOREIGN KEY", "UNIQUE", "CHECK")):
                continue
            
            line = line.rstrip(",")
            parts = line.split()
            
            if len(parts) >= 2:
                col_name = parts[0].strip('"').lower()
                col_type = parts[1].strip('"').lower()
                columns[col_name] = col_type
                
        tables[table_name] = columns

    return tables


def resolve_referenced_table(col_name: str, existing_tables: Set[str]) -> Optional[str]:
    """
    Infere a tabela de destino para uma coluna terminada em '_id'.
    """
    base_name = col_name[:-3]  # Remove o sufixo '_id'
    
    # 1. Checa no dicionário de papéis/aliases conhecidos
    if base_name in ROLE_TO_TABLE_MAP:
        target = ROLE_TO_TABLE_MAP[base_name]
        if target in existing_tables:
            return target

    # 2. Testa as formas no plural (ex: category -> categories)
    for plural in get_plural_candidates(base_name):
        if plural in existing_tables:
            return plural

    # 3. Se o nome base já for o nome exato da tabela
    if base_name in existing_tables:
        return base_name

    # 4. Decomposição por tokens (ex: primary_location -> testa 'location' -> 'locations')
    tokens = base_name.split("_")
    for token in reversed(tokens):
        if token in ROLE_TO_TABLE_MAP:
            target = ROLE_TO_TABLE_MAP[token]
            if target in existing_tables:
                return target
                
        for plural in get_plural_candidates(token):
            if plural in existing_tables:
                return plural
                
        for tbl in existing_tables:
            if tbl.endswith(f"_{token}s") or tbl.endswith(f"_{token}es") or tbl.endswith(f"_{token}"):
                return tbl

    return None


def generate_fk_statements_from_schema(schema_file_path: str) -> str:
    """
    Varre o schema.sql e gera todos os comandos ALTER TABLE para as FKs válidas.
    """
    if not os.path.exists(schema_file_path):
        raise FileNotFoundError(f"O arquivo {schema_file_path} não foi encontrado.")

    with open(schema_file_path, "r", encoding="utf-8") as f:
        schema_content = f.read()

    schema_structure = parse_sql_schema(schema_content)
    all_table_names = set(schema_structure.keys())

    sql_output = [
        "\n-- ========================================================",
        "-- CONFIGURAÇÃO DE CHAVES ESTRANGEIRAS (GERADO DINAMICAMENTE)",
        "-- ========================================================\n"
    ]

    for table_name, columns in schema_structure.items():
        for col_name, col_type in columns.items():
            
            # Filtro 1: Deve terminar em '_id'
            if not col_name.endswith("_id"):
                continue

            # Filtro 2: O tipo de dado deve ser inteiro (descarta falsas FKs como tax_id)
            if col_type != "integer":
                continue

            # Filtro 3: Exceção polimórfica (apenas reference_id em stock_movements é polimórfico)
            if table_name == "stock_movements" and col_name == "reference_id":
                continue

            # Resolve a tabela de destino
            ref_table = resolve_referenced_table(col_name, all_table_names)

            if ref_table:
                constraint_name = f"fk_{table_name}_{col_name}"
                alter_stmt = (
                    f"ALTER TABLE {table_name} "
                    f"ADD CONSTRAINT {constraint_name} "
                    f"FOREIGN KEY ({col_name}) REFERENCES {ref_table}(id);"
                )
                sql_output.append(alter_stmt)

    # Anexa o mecanismo especial de trigger para o caso de stock_movements.reference_id
    if "stock_movements" in schema_structure:
        sql_output.append(generate_stock_movements_trigger_sql())

    return "\n".join(sql_output)

def generate_stock_movements_trigger_sql() -> str:
    """
    Gera o bloco SQL de Trigger/Function corrigido para a FK polimórfica de stock_movements.
    """
    return """
    -- ========================================================
    -- MECANISMO ESPECIAL: TRATAMENTO DE FK POLIMÓRFICA (stock_movements)
    -- ========================================================
    CREATE OR REPLACE FUNCTION check_stock_movement_reference()
    RETURNS TRIGGER AS $$
    DECLARE
        v_exists BOOLEAN := FALSE;
    BEGIN
        IF NEW.reference_table IS NULL OR NEW.reference_id IS NULL THEN
            RETURN NEW;
        END IF;

        -- Cast explícito para tratar a diferença de tipos (INTEGER vs TEXT) 
        -- e remover o sufixo '.0' de números lidos como Float no Python/Pandas
        EXECUTE format(
            'SELECT EXISTS (SELECT 1 FROM %I WHERE id::text = split_part($1::text, ''.'', 1))', 
            NEW.reference_table
        )
        INTO v_exists
        USING NEW.reference_id;

        IF NOT v_exists THEN
            RAISE EXCEPTION 'Chave estrangeira polimórfica inválida: ID % não encontrado na tabela %', 
                NEW.reference_id, NEW.reference_table;
        END IF;

        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

    CREATE OR REPLACE TRIGGER trg_check_stock_movement_reference
    BEFORE INSERT OR UPDATE ON stock_movements
    FOR EACH ROW
    EXECUTE FUNCTION check_stock_movement_reference();
    """

def process_schema_file(schema_file_path: str) -> None:
    """
    Lê o schema.sql e adiciona as FKs e Triggers ao final do arquivo.
    """
    fk_statements = generate_fk_statements_from_schema(schema_file_path)

    with open(schema_file_path, "a", encoding="utf-8") as file:
        file.write("\n" + fk_statements + "\n")

    print(f"[SUCESSO] ALTER TABLEs e Triggers anexados ao arquivo '{schema_file_path}'.")

if __name__ == '__main__':
    os.makedirs(DIRETORIO_CSV, exist_ok=True)
    gerar_sql_com_tipos(DIRETORIO_CSV, ARQUIVO_SAIDA_SQL)
    process_schema_file(ARQUIVO_SAIDA_SQL)
