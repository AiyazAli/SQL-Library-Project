create DATABASE IF NOT EXISTS  Aiyaz;
use   Aiyaz;

 CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100),
    category VARCHAR(50),
    total_quantity INT NOT NULL,
    available_quantity INT NOT NULL,
    CHECK (total_quantity >= 0),
    CHECK (available_quantity >= 0),
    CHECK (available_quantity <= total_quantity)
);
 CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(200)
);
 CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,

    book_id INT NOT NULL,
    user_id INT NOT NULL,

    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,

    status ENUM('ISSUED', 'RETURNED')
    DEFAULT 'ISSUED',

    FOREIGN KEY (book_id)
    REFERENCES Books(book_id),

    FOREIGN KEY (user_id)
    REFERENCES Users(user_id),

    CHECK (due_date >= issue_date)
);

 INSERT INTO books(title, author, category, total_quantity, available_quantity) VALUES
('Java Programming', 'James Gosling',
 'Programming', 5, 5),
('Python Basics', 'Guido van Rossum',
 'Programming', 3, 3),
('Database Management', 'Korth',
 'Database', 4, 4);

 INSERT INTO Users(name, email, phone, address) VALUES
('Amit', 'amit@gmail.com', '9876543210', 'Delhi'),
('Rahul', 'rahul@gmail.com', '9876543211', 'Mumbai'),
('Priya', 'priya@gmail.com', '9876543212', 'Pune');

-- issue a book
START TRANSACTION;

UPDATE Books
SET available_quantity = available_quantity - 1
WHERE book_id = 1
AND available_quantity > 0;

INSERT INTO Transactions
(book_id, user_id, issue_date, due_date)
SELECT 1, 1, CURDATE(),
       DATE_ADD(CURDATE(), INTERVAL 14 DAY)
WHERE ROW_COUNT() = 1;

COMMIT;

-- return a book
START TRANSACTION;

UPDATE Transactions
SET status = 'RETURNED',
    return_date = CURDATE()
WHERE transaction_id = 1
AND status = 'ISSUED';

UPDATE Books
SET available_quantity = available_quantity + 1
WHERE book_id = (
    SELECT book_id
    FROM Transactions
    WHERE transaction_id = 1
);

COMMIT;

-- tracking a book

 SELECT
    T.transaction_id,
    B.title,
    U.name,
    T.issue_date,
    T.due_date,
    T.status

FROM Transactions T

JOIN Books B
ON T.book_id = B.book_id

JOIN Users U
ON T.user_id = U.user_id

WHERE T.status = 'ISSUED';

-- track overdue book
SELECT
    U.name,
    B.title,
    T.issue_date,
    T.due_date

FROM Transactions T

JOIN Users U
ON T.user_id = U.user_id

JOIN Books B
ON T.book_id = B.book_id

WHERE T.status = 'ISSUED'
AND T.due_date < CURDATE();

-- view borrow history

SELECT
    T.transaction_id,
    U.name AS user_name,
    B.title AS book_name,
    T.issue_date,
    T.due_date,
    T.return_date,
    T.status

FROM Transactions T

JOIN Users U
ON T.user_id = U.user_id

JOIN Books B
ON T.book_id = B.book_id

ORDER BY T.transaction_id DESC;

-- display books
SELECT * FROM Books;