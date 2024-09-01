-- Copy order_items table from the public dataset thelook_ecommerce to the local dataset
CREATE TABLE `retail_database.retail_dataset.order_items` AS -- Create the table (order_items) within the local project and dataset 
SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items`; -- Select the external table (order_items) to copy into the local table with the same name

-- Copy products table from the public dataset thelook_ecommerce to the local dataset
CREATE TABLE `retail_database.retail_dataset.products` AS -- Create the table (products) within the local project and dataset
SELECT * FROM `bigquery-public-data.thelook_ecommerce.products`; -- Select the external table (products) to copy into the local table with the same name

-- Copy orders table from the public dataset thelook_ecommerce to the local dataset
CREATE TABLE `retail_database.retail_dataset.orders` AS -- Create the table (orders) within the local project and dataset
SELECT * FROM `bigquery-public-data.thelook_ecommerce.orders`; -- Select the external table (orders) to copy into the local table with the same name

-- Now that the data is within the local dataset, we will extract the cost of each item from the "products" table, "cost" column, and insert it into the "order_items" table

-- Create the columns "cost", "category", "brand", "department" within the order_items table
ALTER TABLE `retail_database.retail_dataset.order_items`
ADD COLUMN cost FLOAT64,
ADD COLUMN category STRING,
ADD COLUMN brand STRING,
ADD COLUMN department STRING;

-- Rename column "deparment" to "department" in the order_items table due to a typo in the previous query
ALTER TABLE `retail_database.retail_dataset.order_items`
RENAME COLUMN deparment TO department;

-- Take the "cost" column from the products table and copy it into the "cost" column of the order_items table
UPDATE `retail_database.retail_dataset.order_items` AS aa -- alias aa for the location of the order_items table

SET aa.cost = ( -- Subqueries per column
  SELECT bb.cost  -- copy it into the "order_items" table
  FROM `retail_database.retail_dataset.products` AS bb -- alias bb for the location of the products table
  WHERE aa.product_id = bb.id -- Where the IDs match so that the product cost is correctly assigned
),
  aa.brand = (
    SELECT bb.brand
    FROM `retail_database.retail_dataset.products` AS bb
    WHERE aa.product_id = bb.id
  ),
  aa.category = (
    SELECT bb.category
    FROM `retail_database.retail_dataset.products` AS bb
    WHERE aa.product_id = bb.id
  ),
  aa.department = (
    SELECT bb.department
    FROM `retail_database.retail_dataset.products` AS bb
    WHERE aa.product_id = bb.id
  )
WHERE EXISTS ( -- Only update rows in the "order_items" table where a matching row exists in the "products" table
  SELECT 1
  FROM `retail_database.retail_dataset.products` AS bb
  WHERE aa.product_id = bb.id
);

