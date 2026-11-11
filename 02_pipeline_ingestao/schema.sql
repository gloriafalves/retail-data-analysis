-- Esquema SQL gerado automaticamente com inferência de tipos

CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    customer_id integer,
    address_type text,
    postal_code text,
    street text,
    number integer,
    complement text,
    district text,
    city text,
    state text,
    country text,
    is_primary boolean
);

CREATE TABLE IF NOT EXISTS attributes (
    id SERIAL PRIMARY KEY,
    name text,
    data_type text
);

CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name text,
    country text,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name text,
    slug text,
    parent_category_id integer,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    person_type text,
    legal_name text,
    trade_name text,
    tax_id text,
    state_registration text,
    email text,
    phone text,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    full_name text,
    cpf text,
    email text,
    role text,
    primary_location_id integer,
    hire_date date,
    termination_date date,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS fiscal_invoices (
    id SERIAL PRIMARY KEY,
    order_id integer,
    nfe_number text,
    nfe_access_key text,
    series text,
    issued_at timestamp,
    status text,
    total_amount real,
    xml_storage_uri text,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS goods_receipts (
    id SERIAL PRIMARY KEY,
    purchase_order_id integer,
    received_by_employee_id integer,
    received_at timestamp,
    notes text,
    created_at timestamp
);

CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id SERIAL PRIMARY KEY,
    goods_receipt_id integer,
    purchase_order_item_id integer,
    quantity_received real
);

CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    name text,
    location_type text,
    postal_code text,
    street text,
    number integer,
    complement text,
    district text,
    city text,
    state text,
    country text,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number text,
    channel text,
    customer_id integer,
    salesperson_id integer,
    location_id integer,
    status text,
    subtotal real,
    discount_amount real,
    total real,
    placed_at timestamp,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id integer,
    product_variant_id integer,
    quantity integer,
    unit_price real,
    icms_rate real,
    ipi_rate real,
    line_total real
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id integer,
    method text,
    installments integer,
    amount real,
    status text,
    paid_at timestamp,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name text,
    description text,
    brand_id integer,
    category_id integer,
    ncm_code text,
    unit_of_measure text,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS product_suppliers (
    product_variant_id integer,
    supplier_id integer,
    supplier_sku text,
    last_quoted_cost real,
    lead_time_days integer,
    is_preferred boolean,
    created_at timestamp,
    updated_at timestamp,
	CONSTRAINT pk_product_suppliers PRIMARY KEY (product_variant_id, supplier_id)
);

CREATE TABLE IF NOT EXISTS product_variants (
    id SERIAL PRIMARY KEY,
    product_id integer,
    sku text,
    barcode_ean text,
    sale_price real,
    cost_price real,
    weight_kg real,
    icms_rate real,
    ipi_rate real,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    po_number text,
    supplier_id integer,
    buyer_id integer,
    destination_location_id integer,
    status text,
    currency text,
    subtotal real,
    total real,
    placed_at timestamp,
    expected_delivery_at date,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id integer,
    product_variant_id integer,
    quantity_ordered integer,
    unit_cost real,
    line_total real
);

CREATE TABLE IF NOT EXISTS returns (
    id SERIAL PRIMARY KEY,
    return_number text,
    order_id integer,
    customer_id integer,
    received_at_location_id integer,
    status text,
    reason text,
    total_refund_amount real,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS return_items (
    id SERIAL PRIMARY KEY,
    return_id integer,
    order_item_id integer,
    quantity real,
    action text,
    exchange_variant_id integer,
    unit_refund_amount real
);

CREATE TABLE IF NOT EXISTS stock_levels (
    product_variant_id integer,
    location_id integer,
    quantity_on_hand real,
    reorder_point text,
    updated_at timestamp,
	CONSTRAINT pk_stock_levels PRIMARY KEY (product_variant_id, location_id)
);

CREATE TABLE IF NOT EXISTS stock_movements (
    id SERIAL PRIMARY KEY,
    product_variant_id integer,
    location_id integer,
    movement_type text,
    quantity real,
    reference_table text,
    reference_id text,
    employee_id text,
    notes text,
    occurred_at timestamp,
    created_at timestamp
);

CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    legal_name text,
    trade_name text,
    country text,
    tax_id text,
    tax_id_type text,
    email text,
    phone text,
    contact_name text,
    is_active boolean,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE IF NOT EXISTS variant_attribute_values (
    product_variant_id integer,
    attribute_id integer,
    value text,
	CONSTRAINT pk_variant_attribute_values PRIMARY KEY (product_variant_id, attribute_id)
);



-- ========================================================
-- CONFIGURAÇÃO DE CHAVES ESTRANGEIRAS (GERADO DINAMICAMENTE)
-- ========================================================

ALTER TABLE addresses ADD CONSTRAINT fk_addresses_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id);
ALTER TABLE categories ADD CONSTRAINT fk_categories_parent_category_id FOREIGN KEY (parent_category_id) REFERENCES categories(id);
ALTER TABLE employees ADD CONSTRAINT fk_employees_primary_location_id FOREIGN KEY (primary_location_id) REFERENCES locations(id);
ALTER TABLE fiscal_invoices ADD CONSTRAINT fk_fiscal_invoices_order_id FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE goods_receipts ADD CONSTRAINT fk_goods_receipts_purchase_order_id FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id);
ALTER TABLE goods_receipts ADD CONSTRAINT fk_goods_receipts_received_by_employee_id FOREIGN KEY (received_by_employee_id) REFERENCES employees(id);
ALTER TABLE goods_receipt_items ADD CONSTRAINT fk_goods_receipt_items_goods_receipt_id FOREIGN KEY (goods_receipt_id) REFERENCES goods_receipts(id);
ALTER TABLE goods_receipt_items ADD CONSTRAINT fk_goods_receipt_items_purchase_order_item_id FOREIGN KEY (purchase_order_item_id) REFERENCES purchase_order_items(id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_salesperson_id FOREIGN KEY (salesperson_id) REFERENCES employees(id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_location_id FOREIGN KEY (location_id) REFERENCES locations(id);
ALTER TABLE order_items ADD CONSTRAINT fk_order_items_order_id FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE order_items ADD CONSTRAINT fk_order_items_product_variant_id FOREIGN KEY (product_variant_id) REFERENCES product_variants(id);
ALTER TABLE payments ADD CONSTRAINT fk_payments_order_id FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE products ADD CONSTRAINT fk_products_brand_id FOREIGN KEY (brand_id) REFERENCES brands(id);
ALTER TABLE products ADD CONSTRAINT fk_products_category_id FOREIGN KEY (category_id) REFERENCES categories(id);
ALTER TABLE product_suppliers ADD CONSTRAINT fk_product_suppliers_product_variant_id FOREIGN KEY (product_variant_id) REFERENCES product_variants(id);
ALTER TABLE product_suppliers ADD CONSTRAINT fk_product_suppliers_supplier_id FOREIGN KEY (supplier_id) REFERENCES suppliers(id);
ALTER TABLE product_variants ADD CONSTRAINT fk_product_variants_product_id FOREIGN KEY (product_id) REFERENCES products(id);
ALTER TABLE purchase_orders ADD CONSTRAINT fk_purchase_orders_supplier_id FOREIGN KEY (supplier_id) REFERENCES suppliers(id);
ALTER TABLE purchase_orders ADD CONSTRAINT fk_purchase_orders_buyer_id FOREIGN KEY (buyer_id) REFERENCES customers(id);
ALTER TABLE purchase_orders ADD CONSTRAINT fk_purchase_orders_destination_location_id FOREIGN KEY (destination_location_id) REFERENCES locations(id);
ALTER TABLE purchase_order_items ADD CONSTRAINT fk_purchase_order_items_purchase_order_id FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id);
ALTER TABLE purchase_order_items ADD CONSTRAINT fk_purchase_order_items_product_variant_id FOREIGN KEY (product_variant_id) REFERENCES product_variants(id);
ALTER TABLE returns ADD CONSTRAINT fk_returns_order_id FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE returns ADD CONSTRAINT fk_returns_customer_id FOREIGN KEY (customer_id) REFERENCES customers(id);
ALTER TABLE returns ADD CONSTRAINT fk_returns_received_at_location_id FOREIGN KEY (received_at_location_id) REFERENCES locations(id);
ALTER TABLE return_items ADD CONSTRAINT fk_return_items_return_id FOREIGN KEY (return_id) REFERENCES returns(id);
ALTER TABLE return_items ADD CONSTRAINT fk_return_items_order_item_id FOREIGN KEY (order_item_id) REFERENCES order_items(id);
ALTER TABLE return_items ADD CONSTRAINT fk_return_items_exchange_variant_id FOREIGN KEY (exchange_variant_id) REFERENCES product_variants(id);
ALTER TABLE stock_levels ADD CONSTRAINT fk_stock_levels_product_variant_id FOREIGN KEY (product_variant_id) REFERENCES product_variants(id);
ALTER TABLE stock_levels ADD CONSTRAINT fk_stock_levels_location_id FOREIGN KEY (location_id) REFERENCES locations(id);
ALTER TABLE stock_movements ADD CONSTRAINT fk_stock_movements_product_variant_id FOREIGN KEY (product_variant_id) REFERENCES product_variants(id);
ALTER TABLE stock_movements ADD CONSTRAINT fk_stock_movements_location_id FOREIGN KEY (location_id) REFERENCES locations(id);
ALTER TABLE variant_attribute_values ADD CONSTRAINT fk_variant_attribute_values_product_variant_id FOREIGN KEY (product_variant_id) REFERENCES product_variants(id);
ALTER TABLE variant_attribute_values ADD CONSTRAINT fk_variant_attribute_values_attribute_id FOREIGN KEY (attribute_id) REFERENCES attributes(id);

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
    
