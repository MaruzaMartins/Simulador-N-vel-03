CREATE DATABASE BibliotecaTelos;

USE BibliotecaTelos;

CREATE TABLE Books (
book_id SMALLINT IDENTITY(1,1) NOT NULL,
title VARCHAR(150) NOT NULL,
uthor VARCHAR(100),
published_year INT,
CONSTRAINT PK_Books PRIMARY KEY (book_id)
); 

CREATE TABLE Users(
user_id SMALLINT IDENTITY(1,1) NOT NULL,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL,
CONSTRAINT PK_Users PRIMARY KEY (user_id)
);

CREATE TABLE Loans (
loan_id SMALLINT IDENTITY(1,1) NOT NULL,
book_id SMALLINT NOT NULL,
user_id SMALLINT NOT NULL,
loan_date DATE NOT NULL,
return_date DATE NULL,
CONSTRAINT PK_Loans PRIMARY KEY (loan_id),
CONSTRAINT FK_id_Books FOREIGN KEY (book_id) REFERENCES Books(book_id),
CONSTRAINT FK_id_Users FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

ALTER TABLE Books DROP COLUMN uthor;
ALTER TABLE Books ADD author VARCHAR(100);

INSERT INTO Books (title, author, published_year)
VALUES 
('O Assassinato No Expresso Oriente', 'Agatha Christie', 1934),
('O Alienista', 'Machado de Assis', 1900),
('A Hora da Estrela','Clarice Lispector', 1977),
('Capitães da Areia', 'Jorge Amado', 1937);

UPDATE Books
SET published_year = 1882
WHERE book_id = 2;

SELECT *FROM Books WHERE title LIKE '%Alienista%' OR author LIKE '%Machado%';

DELETE FROM Books WHERE book_id = 4;

INSERT INTO Users (name, email)
VALUES
('Ana Lima', 'ana@email.com'),
('João Carlos', 'joao@email.com'),
('Matheus Lima', 'lima@email.com'),
('Carlota Joaquina', 'joaquina@emil.com');

UPDATE Users
SET email = 'ana.lima@email.com'
WHERE user_id = 1;

SELECT * FROM Users WHERE name LIKE '%Ana%' OR email LIKE '%email.com%';

DELETE FROM Users
WHERE user_id = 4;

--verificar a disponibilidade do livro
SELECT CASE
    WHEN EXISTS (
        SELECT 1
        FROM Loans
        WHERE book_id = 1
          AND return_date IS NULL
    ) THEN 0
    ELSE 1
END AS is_available;

-- Empréstimo
INSERT INTO Loans (book_id, user_id, loan_date, return_date)
VALUES (2, 2, GETDATE(), NULL);

--devolver livro
UPDATE Loans
SET return_date = GETDATE()
WHERE book_id = 2
  AND return_date IS NULL;

--historico dos livos devolvidos e emprestados
SELECT 
    b.title,
    u.name AS user_name,
    l.loan_date,
    l.return_date,
    CASE 
        WHEN l.return_date IS NULL THEN 'Emprestado'
        ELSE 'Devolvido'
    END AS status
FROM Loans l
JOIN Books b ON b.book_id = l.book_id
JOIN Users u ON u.user_id = l.user_id
ORDER BY l.loan_date DESC;

--livros q ainda estão emprestados
SELECT 
    b.title,
    u.name AS user_name,
    l.loan_date
FROM Loans l
JOIN Books b ON b.book_id = l.book_id
JOIN Users u ON u.user_id = l.user_id
WHERE l.return_date IS NULL
ORDER BY l.loan_date DESC;

-- os user que pegaram mais livros
SELECT TOP 10
    u.user_id,
    u.name,
    COUNT(l.loan_id) AS total_loans
FROM Users u
LEFT JOIN Loans l ON l.user_id = u.user_id
GROUP BY u.user_id, u.name
ORDER BY total_loans DESC;

--encontrar usuários com + de 3 empréstimos - caso tenha
SELECT u.name
FROM Users u
WHERE (
    SELECT COUNT(*)
    FROM Loans l
    WHERE l.user_id = u.user_id
) > 3;

CREATE VIEW vw_HistoricoEmprestimos
AS
SELECT
    l.loan_id,
    b.title,
    u.name AS user_name,
    l.loan_date,
    l.return_date
FROM Loans l
JOIN Books b ON b.book_id = l.book_id
JOIN Users u ON u.user_id = l.user_id;

SELECT *
FROM vw_HistoricoEmprestimos
ORDER BY loan_date DESC;








