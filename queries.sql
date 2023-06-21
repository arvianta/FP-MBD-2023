-- total bookings per branch:

SELECT b.location AS branch_location, COUNT(*) AS total_bookings
FROM bookings bk
LEFT JOIN vehicle v ON bk.vehicle_id = v.id
LEFT JOIN branch b ON v.branch_id = b.id
GROUP BY b.location;

-- feedbacktype yang paling common:

SELECT ft.categories AS type_categories, COUNT(*) AS feedback_count
FROM feedback_type ft
JOIN user_feedback uf ON ft.id = uf.type_id
GROUP BY ft.categories
ORDER BY COUNT(*) DESC;

-- total booking per bulan

SELECT MONTH(booking_date) AS month, COUNT(*) AS total_bookings
FROM bookings
GROUP BY month
ORDER BY month;

OUTER JOIN QUERY

-- semua client sama booking-booking mereka
SELECT u.name, b.id
FROM users u
LEFT JOIN bookings b ON u.id = b.client_id;

-- semua vehicle sama expensenya masing-masing (termasuk yang nggaada expensenya)
SELECT v.name, ve.id
FROM vehicle v
LEFT JOIN vehicle_expenses ve ON v.id = ve.id;

-- semua booking beserta feedbacknya
SELECT b.booking_id, uf.feedback_description
FROM bookings b
LEFT JOIN user_feedback uf ON b.booking_id = uf.bookings_booking_id;



--FUNCTION

–-` function untuk melihat bookings yang dilakukan oleh client
CREATE FUNCTION CountBookingsByClient(clientId INT) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE bookingCount INT;
    
    SELECT COUNT(*) INTO bookingCount
    FROM bookings
    WHERE client_id = clientId;
        
    RETURN bookingCount;
END;

SELECT CountBookingsByClient(1) AS booking_count;


–function untuk melihat total bookings yang ada
DELIMITER //

CREATE FUNCTION `GetTotalBookings`() RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE totalBookings INT;
    
    SELECT COUNT(*) INTO totalBookings
    FROM fp_mbd_revisi.bookings;
    
    RETURN totalBookings;
END//

DELIMITER ;

SELECT GetTotalBookings() AS total_bookings_count;

–function untuk menghitung feedback yang masuk
CREATE FUNCTION `GetTotalFeedbackCount`() RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE feedbackCount INT;
    SELECT COUNT(*) INTO feedbackCount FROM user_feedback;
    RETURN feedbackCount;
END;

SELECT GetTotalFeedbackCount();

PROCEDURE

DELIMITER $$

CREATE PROCEDURE sp_UpdateClientData(
    IN p_client_id INT,
    IN p_client_address VARCHAR(100),
    IN p_client_phone_number VARCHAR(13)
)
BEGIN
    DECLARE v_old_address VARCHAR(100);
    DECLARE v_old_phone_number VARCHAR(13);
    DECLARE v_update_info VARCHAR(200);

    -- Get the old address and phone number of the client
    SELECT address, phone_number
    INTO v_old_address, v_old_phone_number
    FROM users
    WHERE id = p_client_id;

    -- Update client address if provided
    IF p_client_address IS NOT NULL THEN
        UPDATE users
        SET address = p_client_address
        WHERE id = p_client_id;

        SET v_update_info = 'Address';
    END IF;

    -- Update client phone number if provided
    IF p_client_phone_number IS NOT NULL THEN
        UPDATE users
        SET phone_number = p_client_phone_number
        WHERE id = p_client_id;

        SET v_update_info = CONCAT_WS(', ', v_update_info, 'Phone Number');
    END IF;

    -- Raise notice about the changes made
    IF ROW_COUNT() > 0 THEN
        SELECT CONCAT('Client ID: ', p_client_id) AS message;
        SELECT CONCAT('Old Address: ', v_old_address) AS message;
        SELECT CONCAT('Old Phone Number: ', v_old_phone_number) AS message;
        SELECT CONCAT('Updated: ', v_update_info) AS message;
    ELSE
        SELECT CONCAT('Client with ID ', p_client_id, ' not found.') AS message;
    END IF;
END $$

DELIMITER ;

CALL sp_UpdateClientData(600020, 'Jl. ujung berung', '081249112211');

—--------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_GetVehiclesByCategoryAndCapacity(
    IN p_category VARCHAR(255),
    IN p_capacity INT
)
BEGIN
    -- Mengambil daftar kendaraan berdasarkan kategori dan kapasitas
    SELECT *
    FROM vehicle
    WHERE type = p_category AND capacities >= p_capacity;

    -- Menampilkan pesan jika tidak ada kendaraan yang cocok
    IF ROW_COUNT() = 0 THEN
        SELECT 'Tidak ada kendaraan yang cocok dengan kategori dan kapasitas yang diberikan.' AS message;
    END IF;
END $$

DELIMITER ;

CALL sp_GetVehiclesByCategoryAndCapacity('Manual', 8);

INDEXING

ALTER TABLE vehicle ADD INDEX index_vehicle_name (name);
