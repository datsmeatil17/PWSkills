--QUESTION 6--

--- Create database and use it--
CREATE DATABASE IF NOT EXISTS ECommerceDB;
USE ECommerceDB;

-- Categories
CREATE TABLE IF NOT EXISTS Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Products
CREATE TABLE IF NOT EXISTS Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL UNIQUE,
    CategoryID INT,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT,
    CONSTRAINT fk_products_category FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Customers
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    JoinDate DATE
) ENGINE=InnoDB;

-- Orders
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2),
    CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;


--QUESTION 7--

SELECT 
    c.CustomerName,
    c.Email,
    COUNT(o.OrderID) AS TotalNumberOfOrders
FROM 
    Customers c
LEFT JOIN 
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName, c.Email
ORDER BY 
    c.CustomerName;



--QUESTION 8--

SELECT 
    p.ProductName,
    p.Price,
    p.StockQuantity,
    c.CategoryName
FROM 
    Products p
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY 
    c.CategoryName ASC,
    p.ProductName ASC;


--QUESTION 9--
WITH RankedProducts AS (
    SELECT 
        c.CategoryName,
        p.ProductName,
        p.Price,
        ROW_NUMBER() OVER (
            PARTITION BY c.CategoryName 
            ORDER BY p.Price DESC
        ) AS RowNum
    FROM 
        Products p
    JOIN 
        Categories c 
    ON 
        p.CategoryID = c.CategoryID
)
SELECT 
    CategoryName,
    ProductName,
    Price
FROM 
    RankedProducts
WHERE 
    RowNum <= 2
ORDER BY 
    CategoryName,
    Price DESC;

--QUESTION 10--


--Top 5 customers by total amount spent--
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    c.email,
    SUM(p.amount) AS TotalSpent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY TotalSpent DESC
LIMIT 5;

--2. Top 3 movie categories by rental count--
SELECT 
    cat.name AS CategoryName,
    COUNT(r.rental_id) AS RentalCount
FROM category cat
JOIN film_category fc ON cat.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY cat.category_id
ORDER BY RentalCount DESC
LIMIT 3;

-- 3. Films available at each store + how many never rented--
Films available in each store:
SELECT 
    store_id,
    COUNT(inventory_id) AS TotalFilmsAvailable
FROM inventory
GROUP BY store_id;

Films never rented:
SELECT 
    i.store_id,
    COUNT(i.inventory_id) AS FilmsNeverRented
FROM inventory i
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL
GROUP BY i.store_id;

-- 4. Total revenue per month for the year 2023--

(Assuming Sakila has data for 2023—if not, adjust the year.)

SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS Month,
    SUM(amount) AS TotalRevenue
FROM payment
WHERE YEAR(payment_date) = 2023
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY Month;

-- 5. Customers who rented more than 10 times in the last 6 months--
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    COUNT(r.rental_id) AS TotalRentals
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
WHERE r.rental_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.customer_id
HAVING COUNT(r.rental_id) > 10
ORDER BY TotalRentals DESC;