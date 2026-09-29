# Data Dictionary

This document describes the main tables used in the PostgreSQL model and
the Power BI MVP.

## `customers`

  ----------------------------------------------------------------------------
  Column                       Type                    Description
  ---------------------------- ----------------------- -----------------------
  `customer_id`                `VARCHAR(32)`           Primary key. Customer
                                                       record used by an
                                                       order.

  `customer_unique_id`         `VARCHAR(32)`           Logical customer
                                                       identifier used for
                                                       unique-customer
                                                       analysis.

  `customer_zip_code_prefix`   `VARCHAR(5)`            Brazilian ZIP prefix.
                                                       Stored as text to
                                                       preserve leading zeros.

  `customer_city`              `VARCHAR`               Customer city.

  `customer_state`             `CHAR(2)`               Brazilian state code.
  ----------------------------------------------------------------------------

**Grain:** one customer record used in the Olist order model.

## `orders`

  ---------------------------------------------------------------------------------
  Column                            Type                    Description
  --------------------------------- ----------------------- -----------------------
  `order_id`                        `VARCHAR(32)`           Primary key.

  `customer_id`                     `VARCHAR(32)`           Foreign key to
                                                            `customers`.

  `order_status`                    `VARCHAR(32)`           Order status.

  `order_purchase_timestamp`        `TIMESTAMP`             Purchase timestamp.

  `order_approved_at`               `TIMESTAMP`             Approval timestamp.

  `order_delivered_carrier_date`    `TIMESTAMP`             Timestamp delivered to
                                                            carrier.

  `order_delivered_customer_date`   `TIMESTAMP`             Timestamp delivered to
                                                            customer.

  `order_estimated_delivery_date`   `TIMESTAMP`             Estimated delivery
                                                            timestamp.
  ---------------------------------------------------------------------------------

**Grain:** one row per order.

## `order_items`

  Column                  Type              Description
  ----------------------- ----------------- ---------------------------------
  `order_id`              `VARCHAR(32)`     Order identifier.
  `order_item_id`         `INTEGER`         Item sequence within the order.
  `product_id`            `VARCHAR(32)`     Product identifier.
  `seller_id`             `VARCHAR(32)`     Seller identifier.
  `shipping_limit_date`   `TIMESTAMP`       Shipping deadline.
  `price`                 `NUMERIC(10,2)`   Product price.
  `freight_value`         `NUMERIC(10,2)`   Freight value.

**Primary key:** `(order_id, order_item_id)`\
**Grain:** one product/seller item within an order.

## `products`

  ------------------------------------------------------------------------------
  Column                         Type                    Description
  ------------------------------ ----------------------- -----------------------
  `product_id`                   `VARCHAR(32)`           Primary key.

  `product_category_name`        `VARCHAR`               Portuguese category
                                                         name.

  `product_name_lenght`          `INTEGER`               Product-name length.
                                                         Source spelling
                                                         retained.

  `product_description_lenght`   `INTEGER`               Description length.
                                                         Source spelling
                                                         retained.

  `product_photos_qty`           `INTEGER`               Number of product
                                                         photos.

  `product_weight_g`             `INTEGER`               Weight in grams.

  `product_length_cm`            `INTEGER`               Length in cm.

  `product_height_cm`            `INTEGER`               Height in cm.

  `product_width_cm`             `INTEGER`               Width in cm.
  ------------------------------------------------------------------------------

## `sellers`

  Column                     Type            Description
  -------------------------- --------------- --------------------
  `seller_id`                `VARCHAR(32)`   Primary key.
  `seller_zip_code_prefix`   `CHAR(5)`       Seller ZIP prefix.
  `seller_city`              `VARCHAR`       Seller city.
  `seller_state`             `CHAR(2)`       Seller state.

## `order_payments`

  ------------------------------------------------------------------------
  Column                   Type                    Description
  ------------------------ ----------------------- -----------------------
  `order_id`               `VARCHAR(32)`           Foreign key to orders.

  `payment_sequential`     `INTEGER`               Payment-record sequence
                                                   within an order.

  `payment_type`           `VARCHAR`               Payment method.

  `payment_installments`   `INTEGER`               Number of installments.

  `payment_value`          `NUMERIC(10,2)`         Payment amount.
  ------------------------------------------------------------------------

**Primary key:** `(order_id, payment_sequential)`.

## `order_reviews`

  ---------------------------------------------------------------------------
  Column                      Type                    Description
  --------------------------- ----------------------- -----------------------
  `review_id`                 `VARCHAR(32)`           Review identifier; not
                                                      globally unique in the
                                                      source.

  `order_id`                  `VARCHAR(32)`           Foreign key to orders.

  `review_score`              `INTEGER`               Review score.

  `review_comment_title`      `VARCHAR`               Optional title.

  `review_comment_message`    `VARCHAR`               Optional comment.

  `review_creation_date`      `TIMESTAMP`             Review creation
                                                      timestamp.

  `review_answer_timestamp`   `TIMESTAMP`             Review answer
                                                      timestamp.
  ---------------------------------------------------------------------------

**Primary key:** `(review_id, order_id)`.

## `product_category_name_translation`

  ---------------------------------------------------------------------------------
  Column                            Type                    Description
  --------------------------------- ----------------------- -----------------------
  `product_category_name`           `VARCHAR`               Portuguese category
                                                            name; primary key.

  `product_category_name_english`   `VARCHAR`               English translation;
                                                            nullable for unmatched
                                                            source categories.
  ---------------------------------------------------------------------------------

## `geolocation_clean`

  -----------------------------------------------------------------------
  Column                              Description
  ----------------------------------- -----------------------------------
  `geolocation_zip_code_prefix`       Unique ZIP prefix; primary key.

  `geolocation_lat`                   Representative latitude.

  `geolocation_lng`                   Representative longitude.

  `geolocation_city`                  Most frequent city associated with
                                      the ZIP.

  `geolocation_state`                 State associated with the selected
                                      city/state combination.
  -----------------------------------------------------------------------

**Grain:** one row per ZIP prefix.

The table is an analytical lookup rather than an enforced parent of all
customer/seller ZIPs because source coverage is incomplete.
