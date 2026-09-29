-- 04_constraints.sql
-- Constraints added after profiling and cleaning.

-- order_items references.
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

-- Two source categories were missing from the translation lookup.
-- Preserve referential integrity without inventing English translations.
INSERT INTO product_category_name_translation
    (product_category_name, product_category_name_english)
VALUES
    ('portateis_cozinha_e_preparadores_de_alimentos', NULL),
    ('pc_gamer', NULL)
ON CONFLICT (product_category_name) DO NOTHING;

ALTER TABLE products
ADD CONSTRAINT fk_products_category_translation
FOREIGN KEY (product_category_name)
REFERENCES product_category_name_translation(product_category_name);

-- Intentionally NOT added:
-- customers.customer_zip_code_prefix -> geolocation_clean
-- sellers.seller_zip_code_prefix    -> geolocation_clean
--
-- Reason: source geographic coverage is incomplete. Enforcing those FKs would
-- reject valid business records whose ZIP prefix is absent from geolocation.
