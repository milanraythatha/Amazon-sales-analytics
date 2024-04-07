create database if not exists amazon;
use amazon;
show tables;

DROP TABLE amazon_preprocessed;

create table amazon_preprocessed (
	product_id varchar(50) NOT NULL,
    product_name text,
    category text,
    discounted_price numeric(10,2),
    actual_price numeric(10,2),
    discount_percentage numeric(10,2),
    rating numeric(10,2),
    rating_count numeric(10,2),
    about_product text,
    user_id text,
    user_name varchar(150),
    review_id varchar(150),
    review_title varchar(500),
    review_content text,
    img_link varchar(300),
    product_link varchar(300)
    );
    
    LOAD DATA LOCAL INFILE 	'D:/Study/UNIVERSITY/OTHER COURSES/random coding/Amazon Dataset/amazon_preprocessed.csv'
    INTO TABLE amazon_preprocessed
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 ROWS (product_id, product_name, category, discounted_price,actual_price, discount_percentage, rating, rating_count,about_product, user_id, user_name, review_id, review_title,review_content, img_link, product_link);

ALTER TABLE amazon_preprocessed
ADD PRIMARY KEY (product_id);

CREATE TABLE product(
	product_id varchar(50) NOT NULL PRIMARY KEY,
    product_name text,
    category text,
    discounted_price numeric(10,2),
    actual_price numeric(10,2),
    discount_percentage numeric(10,2),
    rating numeric(10,2),
    rating_count numeric(10,2),
    about_product text);
    
INSERT INTO product (product_id, product_name, category, discounted_price,actual_price, discount_percentage, rating, rating_count,about_product)
SELECT product_id, product_name, category, discounted_price,actual_price, discount_percentage, rating, rating_count,about_product FROM amazon_preprocessed;


CREATE TABLE product_link (
product_id varchar(50) NOT NULL PRIMARY KEY,
img_link varchar(300),
product_link varchar(300),
FOREIGN KEY (product_id) REFERENCES product(product_id));

INSERT INTO product_link (product_id, img_link, product_link)
SELECT product_id, img_link, product_link FROM amazon_preprocessed;

CREATE TABLE review (
	product_id varchar(50) NOT NULL PRIMARY KEY,
    user_id text,
    user_name varchar(150),
    review_id varchar(150),
    review_title varchar(500),
    review_content text,
    FOREIGN KEY (product_id) REFERENCES product(product_id));
    
INSERT INTO review(product_id, user_id, user_name, review_id, review_title,review_content)
SELECT product_id, user_id, user_name, review_id, review_title,review_content FROM amazon_preprocessed;

-- What are the top 5 categories with the highest number of products?
SELECT 
    category, COUNT(DISTINCT product_id) AS no_of_products
FROM
    product
GROUP BY category
ORDER BY no_of_products DESC
LIMIT 5;

-- What is the average discount percentage across all products?
SELECT 
    AVG(discounted_price)
FROM
    product;
    
-- How many products have a discount percentage greater than 20%?
SELECT 
    COUNT(product_id)
FROM
    product
WHERE
    discounted_price > 20;

-- What is the average rating for each category?
SELECT 
    category, AVG(rating) AS average_rating
FROM
    product
GROUP BY category
ORDER BY average_rating DESC;

-- Which product has the highest actual price?
SELECT 
    product_id, product_name, actual_price
FROM
    product
HAVING actual_price = (SELECT 
        MAX(actual_price)
    FROM
        product);

-- How many users have written reviews for multiple products?
SELECT user_id, COUNT(review_id) as no_of_reviews
FROM review
GROUP BY user_id
HAVING COUNT(review_id) >=2
ORDER BY no_of_reviews DESC
;

-- What is the distribution of ratings across all products?
SELECT 
    rating, COUNT(rating) AS freq
FROM
    product
GROUP BY rating
ORDER BY rating DESC;

-- Which user has written the most reviews?
SELECT user_id, user_name, count(review_id) as no_of_reviews
FROM review
GROUP BY user_id, user_name
ORDER BY no_of_reviews DESC
LIMIT 1;

-- What are the top 5 products with the highest number of reviews?
SELECT 
    p.product_id, p.product_name, no_of_reviews
FROM
    (SELECT 
        product_id, COUNT(review_id) AS no_of_reviews
    FROM
        review
    GROUP BY product_id
    ORDER BY no_of_reviews DESC
    LIMIT 5) rev_tab
        JOIN
    product p ON rev_tab.product_id = p.product_id;
    
-- What is the average length of review content for each category?
SELECT 
    category, AVG(LENGTH(review_content)) as average_length
FROM
    review r
        JOIN
    product p ON r.product_id = p.product_id
GROUP BY category
ORDER BY average_length DESC;

SELECT 
    p.product_id,category, LENGTH(review_content)
FROM
    review r JOIN product p on p.product_id = r.product_id
ORDER BY LENGTH(review_content) DESC;


-- How many products have no reviews?
SELECT 
    product_id
FROM
    review
GROUP BY product_id
HAVING COUNT(review_id) = 0
;

-- What is the average discounted price for products in each category?
SELECT 
    category, AVG(discounted_price)
FROM
    product
GROUP BY category
ORDER BY AVG(discounted_price) DESC;

-- What is the average discount percentage for products with a rating greater than 4?
SELECT 
    AVG(discount_percentage) AS avg_dp_ratingover4
FROM
    (SELECT 
        product_id, discount_percentage, rating
    FROM
        product
    WHERE
        rating > 4) a;
        
-- Which user has given the most reviews for products with a rating of 5?
SELECT user_id, user_name, COUNT(review_id) as no_of_reviews
FROM review r JOIN product p on r.product_id = p.product_id
WHERE rating =5
GROUP BY user_id,user_name;

-- How many products have a discount percentage greater than the average discount percentage?
SELECT 
    COUNT(product_id) AS no_of_products_above_avgdp
FROM
    product
WHERE
    discount_percentage > (SELECT 
            AVG(discount_percentage)
        FROM
            product);
            
-- What is the average rating count for products with a discount percentage greater than 30%?

SELECT 
    AVG(rating_count)
FROM
    product
WHERE
    discount_percentage > 30;
    
-- How many products have a rating count less than 10?
SELECT 
    COUNT(product_id)
FROM
    product
WHERE
    rating_count < 10;

-- What is the average length of review content for products with a rating greater than 4?
SELECT 
    AVG(LENGTH(review_content)) as average_length
FROM
    review r
        JOIN
    product p ON r.product_id = p.product_id
WHERE
    rating > 4;

-- How many products have a higher actual price than discounted price?
SELECT 
    COUNT(product_id) no_of_reviews
FROM
    product
WHERE
    actual_price > discounted_price;
    
-- What is the average rating for products with a review content length greater than 100 characters?
SELECT 
    AVG(rating) AS average_rating
FROM
    product p
        JOIN
    review r ON p.product_id = r.product_id
WHERE
    LENGTH(review_content) > 100;
    
-- What is the average rating count for products in each category, considering only products with a rating greater than 4?

SELECT 
    category, AVG(rating_count)
FROM
    product
WHERE
    rating > 4
GROUP BY category
ORDER BY AVG(rating_count) DESC;

-- How many users have given reviews for products in each category, considering only products with a discount percentage greater than 20%?
SELECT 
    category, COUNT(DISTINCT user_id) AS no_of_users
FROM
    product p
        JOIN
    review r ON p.product_id = r.product_id
WHERE
    discount_percentage > 20
GROUP BY category
ORDER BY no_of_users DESC;

/* What is the average rating for products with a 
review content length greater than the average review content length, grouped by category? */

SELECT 
    category, AVG(rating) as avg_rating
FROM
    product p
        JOIN
    review r ON p.product_id = r.product_id
WHERE LENGTH(review_content) > (SELECT 
        AVG(LENGTH(review_content))
    FROM
        review)
GROUP BY category
ORDER BY avg_rating DESC;

/* How many users have given reviews for products in each category, 
considering only products with a rating greater than average rating 
and a discount percentage greater than 20%? */

SELECT 
    category, COUNT(DISTINCT user_id) AS no_user_reviewing
FROM
    product p
        JOIN
    review r ON p.product_id = r.product_id
WHERE
    rating > (SELECT AVG(rating) FROM product) AND discount_percentage > 20
        AND 
        ISNULL(review_id) = FALSE
GROUP BY category
ORDER BY no_user_reviewing DESC;

-- Lists all categories, displaying their products ranked by ratings within each category
SELECT category, product_id,
COUNT(*) OVER (PARTITION BY category) AS total_products,
DENSE_RANK() OVER (partition by category order by rating DESC) as rating_rank
FROM product
ORDER BY category ASC;




