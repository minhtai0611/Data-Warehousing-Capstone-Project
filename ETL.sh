#!/bin/sh

## Write your code here to load the data from sales_data table in Mysql server to a sales.csv.Select the data which is not more than 4 hours old from the current time.

#Hint: To load the data from a table to a csv file you can refer to the following example syntax:
mysql -h mysql -P 3306 -u root --password=5pokXFaAUlPc4Va3tBBesQaB \
--database=sales --execute=" select * from sales_data" \
--batch --silent > /home/project/sales.csv

#This command connects to a MySQL server, executes a SELECT query to fetch specific columns from a specified table in a database, and saves the query results as a CSV file.

#The output options --batch: Causes MySQL to output rows with tab-separated values. This is useful for scripting.

#--silent: Suppresses the display of query output.

#The csv generated will have tabs. We then replace all the tabs by commas by executing the command below:

tr '\t' ',' < /home/project/sales.csv > /home/project/temp_sales_commas.csv

# Move the temporary file with commas to the original file location
mv /home/project/temp_sales_commas.csv /home/project/sales.csv

 export PGPASSWORD=8ui5GDVkqzRUeIprytKuOhxm;

 psql --username=postgres --host=postgres --dbname=sales_new -c \
 "\COPY sales_data(rowid,product_id,customer_id,price,quantity,timestamp) \
 FROM '/home/project/sales.csv' delimiter ',' csv header;" 




 ## Delete sales.csv present in location /home/project

 ## Write your code here to load the DimDate table from the data present in sales_data table

 psql --username=postgres --host=postgres --dbname=sales_new -c \
 "INSERT INTO DimDate (dateid, day, month, year) SELECT DISTINCT ROW_NUMBER() \ 
 OVER (ORDER BY timestamp) AS dateid, EXTRACT(DAY FROM timestamp) AS day, \
 EXTRACT(MONTH FROM timestamp) AS month, EXTRACT(YEAR FROM timestamp) AS year \
 FROM sales_data;"

## Write your code here to load the FactSales table from the data present in sales_data table

psql --username=postgres --host=postgres --dbname=sales_new -c \
"INSERT INTO FactSales (rowid, product_id, customer_id, price, total_price) \
SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY timestamp) AS rowid, product_id, \
customer_id, price, (price * quantity) AS total_sales FROM sales_data;"

 ## Write your code here to export DimDate table to a csv

 psql --username=postgres --host=postgres --dbname=sales_new -c \
 "\COPY DimDate TO '/home/project/DimDate.csv' DELIMITER ',' CSV HEADER;"

 ## Write your code here to export FactSales table to a csv
 
 psql --username=postgres --host=postgres --dbname=sales_new -c \
 "\COPY FactSales TO '/home/project/FactSales.csv' DELIMITER ',' CSV HEADER;"

psql --username=postgres --host=localhost --dbname=sales_new -c "DROP TABLE IF EXISTS DimDate, FactSales;"

