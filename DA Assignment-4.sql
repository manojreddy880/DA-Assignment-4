-- 1) Identify a table that violates 1NF in Sakila and Explain how you can achieve it.
/* One table in the Sakila database that may violate the First Normal Form (1NF) is the film table due to the special_features column. In the Sakila database, the film table has a column named special_features that stores a comma-separated list of special features associated with each film.*/
CREATE TABLE film_updated1 (
    film_id INT PRIMARY KEY,
    title VARCHAR(255));
CREATE TABLE special_feature_updated (
    feature_id INT PRIMARY KEY,
    feature_name VARCHAR(255)
);
CREATE TABLE film_special_feature_updated (
    film_id INT,
    feature_id INT,
    PRIMARY KEY (film_id, feature_id),
    FOREIGN KEY (film_id) REFERENCES film_updated(film_id),
    FOREIGN KEY (feature_id) REFERENCES special_feature_updated(feature_id)
);

-- 2) Choose a table in Sakila and describe how you would determine whether it is in 2NF If it violates 2NF, explain the steps to Normalize it
/* Let's consider the film table in the Sakila database. In the Sakila database, the film table is related to other tables such as language, category, and actor. To determine whether it is in Second Normal Form (2NF), we need to check for partial dependencies. If there are any, we can normalize it by creating separate tables for related attributes.
The Second Normal Form (2NF) states that a table should be in 1NF, and all non-prime attributes (attributes not part of the primary key) should be fully functionally dependent on the entire primary key.
Here's how you could normalize the film table to achieve 2NF:*/
CREATE TABLE film_updated (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    category_id INT,
    language_id INT
    -- Other attributes
);
CREATE TABLE category_updated (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
);
CREATE TABLE language_updated (
    language_id INT PRIMARY KEY,
    language_name VARCHAR(255)
);

-- 3) Choose a table in Sakila and describe how you would determine whether it is in 3NF If it violates 3NF, explain the steps to Normalize it.
/* Let's consider the film table in the Sakila database. In the Sakila database, the film table is related to other tables such as category, language, and actor. To determine whether it is in Third Normal Form (3NF), we need to check for transitive dependencies. If there are any, we can normalize it by creating separate tables for related attributes.
The Third Normal Form (3NF) states that a table should be in 2NF, and no transitive dependencies should exist. In other words, every non-prime attribute (attributes not part of the primary key) should be directly dependent on the primary key.
Here's how you could normalize the film table to achieve 3NF:*/
CREATE TABLE film_updated (
    film_id INT PRIMARY KEY,
    title VARCHAR(255),
    category_id INT,
    language_id INT
    -- Other attributes
);
CREATE TABLE actor_updated (
    actor_id INT PRIMARY KEY,
    actor_name VARCHAR(255)
);
CREATE TABLE film_actor_updated (
    film_id INT,
    actor_id INT,
    PRIMARY KEY (film_id, actor_id),
    FOREIGN KEY (film_id) REFERENCES film_updated(film_id),
    FOREIGN KEY (actor_id) REFERENCES actor_updated(actor_id)
);

-- 4) Take a specific table in Sakila and guide through the process of Normalizing it from the initial unnormalized form up to at least 2NF
/* Let's consider the rental table in the Sakila database. The rental table is related to other tables such as customer and inventory. We will guide through the process of normalizing it from the initial unnormalized form up to 2NF.
Step 1: Initial Unnormalized Form (UNF)*/
CREATE TABLE rental_updated (
    rental_id INT PRIMARY KEY,
    rental_date DATETIME,
    inventory_id INT,
    customer_id INT,
    return_date DATETIME
    -- Other attributes
);

/*Step 2: Identify Partial Dependencies
No partial dependencies in this example.

Step 3: Identify Transitive Dependencies
No transitive dependencies in this example.

Step 4: Normalize to 1NF
The rental table is already in First Normal Form (1NF).

Step 5: Normalize to 2NF
The rental table is also already in Second Normal Form (2NF) since there are no partial dependencies on a composite primary key.

In this case, the rental table did not exhibit partial or transitive dependencies, so no further normalization was necessary.*/

-- 5) Write a query using a CTE to retrieve the distinct list of actor Names and the Number of films they have acted in from the actor and film_actor tables
WITH ActorFilmCount AS (
    SELECT
        fa.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(fa.film_id) AS film_count
    FROM
        film_actor_updated fa
    JOIN
        actor_updated a ON fa.actor_id = a.actor_id
    GROUP BY
        fa.actor_id, actor_name
)
SELECT
    actor_name,
    film_count
FROM
    ActorFilmCount;

-- 6) Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the category_updated table in Sakila
WITH RECURSIVE CategoryHierarchy AS (
  -- Anchor member: Select top-level categories (categories without a parent)
  SELECT category_id, name, parent_id, 0 as level
  FROM category_updated
  WHERE parent_id IS NULL

  UNION ALL

  -- Recursive member: Join with the category_updated table
  SELECT c.category_id, c.name, c.parent_id, ch.level + 1
  FROM category_updated c
  JOIN CategoryHierarchy ch ON c.parent_id = ch.category_id
)
SELECT * FROM CategoryHierarchy;

-- 7)Create a CTE that combines information from the film_updated and language_updated tables to display the film title, language Name, and rental rate
WITH FilmLanguageInfo AS (
    SELECT
        f.title AS film_title,
        l.language_name,
        f.rental_rate
    FROM
        film_updated f
    JOIN
        language_updated l ON f.language_id = l.language_id
)
SELECT
    film_title,
    language_name,
    rental_rate
FROM
    FilmLanguageInfo;

-- 8)Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer and payment tables
WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue
    FROM
        customer_updated c
    JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    total_revenue
FROM
    CustomerRevenue;

-- 9) Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from the customer and parents tables
WITH CustomerRevenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue
    FROM
        customer_updated c
    LEFT JOIN
        payment p ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    total_revenue
FROM
    CustomerRevenue;

-- 10)Utilize a CTE with a window function to rank films based on their rental duration from the film_updated table
WITH FilmRentalRank AS (
    SELECT
        title,
        rental_duration,
        RANK() OVER (ORDER BY rental_duration DESC) AS rental_rank
    FROM
        film_updated
)
SELECT
    title,
    rental_duration,
    rental_rank
FROM
    FilmRentalRank;

-- 11)Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer_updated table to retrieve additional customer details
WITH CustomersWithMoreThanTwoRentals AS (
    SELECT
        r.customer_id,
        COUNT(*) AS rental_count
    FROM
        rental_updated r
    GROUP BY
        r.customer_id
    HAVING
        COUNT(*) > 2
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    -- Add other customer details as needed
    cm.rental_count
FROM
    CustomersWithMoreThanTwoRentals cm
JOIN
    customer_updated c ON cm.customer_id = c.customer_id;

-- 12)Write a query using a CTE to find the total number of rentals made each month, considering the rental_date from the rental_updated table
WITH MonthlyRentals AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(*) AS total_rentals
    FROM
        rental_updated
    GROUP BY
        rental_month
)
SELECT
    rental_month,
    total_rentals
FROM
    MonthlyRentals;

-- 13)Use a CTE to pivot the data from the payment table to display the total payments made by each customer in separate columns for different payment methods
WITH PaymentPivot AS (
    SELECT
        customer_id,
        SUM(CASE WHEN staff_id IS NULL THEN amount ELSE 0 END) AS total_cash_payments,
        SUM(CASE WHEN staff_id IS NOT NULL THEN amount ELSE 0 END) AS total_credit_card_payments
    FROM
        payment
    GROUP BY
        customer_id
)
SELECT
    pp.customer_id,
    c.first_name,
    c.last_name,
    pp.total_cash_payments,
    pp.total_credit_card_payments
FROM
    PaymentPivot pp
JOIN
    customer_updated c ON pp.customer_id = c.customer_id;

-- 14)Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, using the film_actor_updated table
WITH ActorPairs AS (
    SELECT
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id,
        f.film_id,
        f.title AS film_title
    FROM
        film_actor_updated fa1
    JOIN
        film_actor_updated fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
    JOIN
        film_updated f ON fa1.film_id = f.film_id
)
SELECT
    ap.actor1_id,
    a1.first_name AS actor1_first_name,
    a1.last_name AS actor1_last_name,
    ap.actor2_id,
    a2.first_name AS actor2_first_name,
    a2.last_name AS actor2_last_name,
    ap.film_id,
    ap.film_title
FROM
    ActorPairs ap
JOIN
    actor_updated a1 ON ap.actor1_id = a1.actor_id
JOIN
    actor_updated a2 ON ap.actor2_id = a2.actor_id
ORDER BY
    ap.film_id, ap.actor1_id, ap.actor2_id;

-- 15)Implement a recursive CTE to find all employees in the staff_updated table who report to a specific manager, considering the reports_to column.
WITH RECURSIVE EmployeeHierarchy AS (
  SELECT
      staff_id,
      first_name,
      last_name,
      reports_to,
      0 AS level
  FROM
      staff_updated
  WHERE
      staff_id = 2 -- Specify the manager_id here

  UNION ALL

  SELECT
      s.staff_id,
      s.first_name,
      s.last_name,
      s.reports_to,
      eh.level + 1
  FROM
      staff_updated s
  JOIN
      EmployeeHierarchy eh ON s.reports_to = eh.staff_id
)
SELECT
    *
FROM
    EmployeeHierarchy;
