CREATE TABLE customers(
  id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(30),
  lastname VARCHAR(30),
  email VARCHAR(30),
  zipcode INT(10),
  timecreated TIMESTAMP
);

INSERT INTO customers (firstname, lastname, email,zipcode,timecreated ) VALUES ('har', 'Sh', 'har.sh@example.com',23456,NOW());