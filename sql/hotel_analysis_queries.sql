-- Limpieza básica de la tabla
CREATE TABLE hotel_clean AS
SELECT
    hotel,
    is_canceled,
    lead_time,
    arrival_date_year,
    arrival_date_month,
    stays_in_weekend_nights,
    stays_in_week_nights,
    adults,
    children,
    market_segment,
    distribution_channel,
    adr,
    (adr * (stays_in_weekend_nights + stays_in_week_nights)) AS potential_revenue
FROM hotel_bookings
WHERE hotel IS NOT NULL
  AND market_segment IS NOT NULL;

/* 
* Cancelaciones totales y porcentajes agrupados por hotel. 
* Responde a la pregunta ¿Cuál es el porcentaje de cancelaciones por hotel?
*
*/  
SELECT
	hotel,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS total_canceled,
    ROUND(SUM(is_canceled)* 100.0 / COUNT(*), 2) AS pct_canceled
FROM hotel_clean
GROUP BY hotel
ORDER BY pct_canceled DESC;

/*
* Se muestra el canal de venta, el número de reservas totales,
* la suma de las cancelaciones y el porcentaje de cancelaciones respecto a las reservas totales. 
*/
SELECT
	market_segment,
    COUNT(*) AS total_bookings,
    SUM(is_canceled) AS canceled_count,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS pct_canceled
FROM hotel_clean
GROUP BY market_segment
ORDER BY pct_canceled DESC;

/*
* Cancelaciones agrupadas por su antelación.
*/
SELECT
	CASE
		WHEN lead_time <= 7 THEN 'Last Minute'
        WHEN lead_time BETWEEN 8 AND 30 THEN 'Short Term'
        ELSE 'Early Bird'
	END AS booking_window,
    COUNT(*) AS total_bookings, 
    SUM(is_canceled) AS canceled_count,
    ROUND(SUM(is_canceled) * 100.0 / COUNT(*), 2) AS pct_canceled
FROM hotel_clean
GROUP BY booking_window
ORDER BY FIELD(booking_window, 'Last Minute', 'Short Term', 'Early Bird');

-- Ingresos potenciales vs pérdida por cancelación
SELECT
	market_segment, 
    SUM(potential_revenue) AS total_potential_revenue,
    SUM(potential_revenue * is_canceled) AS revenue_lost, 
    ROUND((SUM(potential_revenue * is_canceled) * 100.0) /
			SUM(potential_revenue), 2) AS pct_revenue_lost
FROM hotel_clean
GROUP BY market_segment
ORDER BY pct_revenue_lost DESC;