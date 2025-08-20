-- SQL Project: Traffic Management System
CREATE DATABASE TrafficDB;
USE TrafficDB;

-- Create Tables
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY,
    plate_number VARCHAR(20),
    owner_name VARCHAR(100),
    vehicle_type VARCHAR(50)
);

CREATE TABLE Roads (
    road_id INT PRIMARY KEY,
    road_name VARCHAR(100),
    city VARCHAR(50),
    speed_limit INT
);

CREATE TABLE Violations (
    violation_id INT PRIMARY KEY,
    vehicle_id INT,
    road_id INT,
    violation_type VARCHAR(50),
    fine_amount DECIMAL(10,2),
    violation_date DATE,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (road_id) REFERENCES Roads(road_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    violation_id INT,
    payment_date DATE,
    payment_method VARCHAR(50),
    amount DECIMAL(10,2),
    FOREIGN KEY (violation_id) REFERENCES Violations(violation_id)
);

-- Alter: add column
ALTER TABLE Vehicles ADD contact_number VARCHAR(15);

-- Insert Data
INSERT INTO Vehicles VALUES
(1, 'AP05AB1234', 'Ravi Kumar', 'Car', '9876543210'),
(2, 'TS09CD5678', 'Anil Reddy', 'Bike', '9876500012'),
(3, 'KA03EF9876', 'Suma Rao', 'Truck', '9876511111');

INSERT INTO Roads VALUES
(101, 'MG Road', 'Hyderabad', 50),
(102, 'Ring Road', 'Bangalore', 80);

INSERT INTO Violations VALUES
(201, 1, 101, 'Over Speed', 500.00, '2025-01-10'),
(202, 2, 101, 'Signal Jump', 1000.00, '2025-01-15'),
(203, 3, 102, 'Over Speed', 1500.00, '2025-02-05');

INSERT INTO Payments VALUES
(301, 201, '2025-01-12', 'Credit Card', 500.00),
(302, 202, '2025-01-20', 'UPI', 1000.00);

-- Update Example
UPDATE Vehicles
SET contact_number = '9999999999'
WHERE vehicle_id = 1;

-- Delete Example
DELETE FROM Payments
WHERE payment_id = 302;

-- WHERE Example
SELECT * FROM Violations
WHERE fine_amount > 800;

-- Aggregate Functions
SELECT COUNT(*) AS total_violations, SUM(fine_amount) AS total_fines
FROM Violations;

-- GROUP BY + HAVING
SELECT violation_type, COUNT(*) AS cases, SUM(fine_amount) AS total_fines
FROM Violations
GROUP BY violation_type
HAVING COUNT(*) > 1;

-- LIKE Example
SELECT * FROM Vehicles
WHERE owner_name LIKE 'R%';

-- Subquery Example
SELECT owner_name
FROM Vehicles
WHERE vehicle_id IN (
    SELECT vehicle_id
    FROM Violations
    WHERE fine_amount > 1000
);

-- Stored Procedure
DELIMITER //
CREATE PROCEDURE GetVehicleFines(IN v_id INT)
BEGIN
    SELECT v.owner_name, SUM(fine_amount) AS total_fine
    FROM Violations vio
    JOIN Vehicles v ON vio.vehicle_id = v.vehicle_id
    WHERE v.vehicle_id = v_id
    GROUP BY v.owner_name;
END //
DELIMITER ;

CALL GetVehicleFines(1);

-- Trigger: Auto insert payment log when violation added
DELIMITER //
CREATE TRIGGER AutoPaymentInsert
AFTER INSERT ON Violations
FOR EACH ROW
BEGIN
    INSERT INTO Payments(payment_id, violation_id, payment_date, payment_method, amount)
    VALUES (NEW.violation_id + 300, NEW.violation_id, CURDATE(), 'Pending', NEW.fine_amount);
END 
//
DELIMITER ;

