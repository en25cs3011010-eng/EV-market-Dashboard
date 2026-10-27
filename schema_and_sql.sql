-- MySQL 8. Run in order.
CREATE DATABASE IF NOT EXISTS ev_market;
USE ev_market;

DROP TABLE IF EXISTS ev_vehicles;
CREATE TABLE ev_vehicles (
  vehicle_id VARCHAR(20) PRIMARY KEY,
  model_name VARCHAR(50), manufacturer VARCHAR(50), model_year INT,
  manufacturing_country VARCHAR(30), market_region VARCHAR(30), category VARCHAR(40),
  battery_capacity_kwh DECIMAL(8,2), battery_type VARCHAR(20), battery_cycle_life DECIMAL(8,1),
  battery_degradation_pct_5yr DECIMAL(6,2), range_km DECIMAL(7,1), efficiency_wh_per_km DECIMAL(8,2),
  motor_power_kw DECIMAL(7,1), torque_nm DECIMAL(8,1), num_motors INT, drivetrain VARCHAR(10),
  top_speed_kmph DECIMAL(6,1), acceleration_0_100_sec DECIMAL(5,2), max_dc_charging_kw DECIMAL(6,1),
  charging_dc_fast_time_min DECIMAL(5,1), charging_ac_time_hr DECIMAL(5,2), num_charging_ports INT,
  num_seats INT, weight_kg DECIMAL(8,1), cargo_capacity_liters DECIMAL(8,1), price_usd DECIMAL(12,2),
  insurance_cost_usd_yearly DECIMAL(10,2), warranty_years INT, resale_value_pct_3yr DECIMAL(5,2),
  safety_rating_stars INT, autonomous_level INT, infotainment_screen_inch DECIMAL(4,1),
  co2_saved_tons_per_year DECIMAL(6,3), annual_sales_units DECIMAL(12,0), customer_rating DECIMAL(3,2),
  recommended_use_case VARCHAR(40), dataset_split VARCHAR(10)
);

-- Load (empty cells -> NULL). Adjust path; enable local_infile if needed.
LOAD DATA LOCAL INFILE 'ev_market_clean.csv' INTO TABLE ev_vehicles
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(vehicle_id,model_name,manufacturer,model_year,manufacturing_country,market_region,category,
 battery_capacity_kwh,battery_type,@cycle,battery_degradation_pct_5yr,range_km,efficiency_wh_per_km,
 motor_power_kw,torque_nm,num_motors,drivetrain,top_speed_kmph,acceleration_0_100_sec,max_dc_charging_kw,
 charging_dc_fast_time_min,charging_ac_time_hr,num_charging_ports,num_seats,weight_kg,cargo_capacity_liters,
 price_usd,insurance_cost_usd_yearly,warranty_years,@resale,safety_rating_stars,autonomous_level,@screen,
 co2_saved_tons_per_year,@sales,@rating,recommended_use_case,dataset_split)
SET battery_cycle_life=NULLIF(@cycle,''), resale_value_pct_3yr=NULLIF(@resale,''),
    infotainment_screen_inch=NULLIF(@screen,''), annual_sales_units=NULLIF(@sales,''),
    customer_rating=NULLIF(@rating,'');

CREATE INDEX idx_mfr ON ev_vehicles(manufacturer);
CREATE INDEX idx_cat ON ev_vehicles(category);
CREATE INDEX idx_year ON ev_vehicles(model_year);

-- ===== SQL operations =====
SELECT COUNT(*) AS rows_loaded FROM ev_vehicles;

-- 1 Sales by category
SELECT category, SUM(annual_sales_units) sales, ROUND(AVG(customer_rating),2) avg_rating
FROM ev_vehicles GROUP BY category ORDER BY sales DESC;

-- 2 Top 10 manufacturers + market share
SELECT manufacturer, SUM(annual_sales_units) sales,
 ROUND(100*SUM(annual_sales_units)/(SELECT SUM(annual_sales_units) FROM ev_vehicles),2) share_pct
FROM ev_vehicles GROUP BY manufacturer ORDER BY sales DESC LIMIT 10;

-- 3 Battery type adoption
SELECT battery_type, COUNT(*) models, SUM(annual_sales_units) sales,
 ROUND(AVG(range_km),1) avg_range, ROUND(AVG(battery_degradation_pct_5yr),2) avg_degradation
FROM ev_vehicles GROUP BY battery_type ORDER BY sales DESC;

-- 4 Production by country
SELECT manufacturing_country, COUNT(*) models, SUM(annual_sales_units) sales
FROM ev_vehicles GROUP BY manufacturing_country ORDER BY sales DESC;

-- 5 YoY growth by category (window function)
WITH y AS (SELECT category, model_year, SUM(annual_sales_units) s FROM ev_vehicles GROUP BY category, model_year)
SELECT category, model_year, s, ROUND(100*(s-LAG(s) OVER (PARTITION BY category ORDER BY model_year))
 /LAG(s) OVER (PARTITION BY category ORDER BY model_year),2) yoy_pct FROM y;

-- 6 Range by category and battery
SELECT category, battery_type, ROUND(AVG(range_km),1) avg_range FROM ev_vehicles GROUP BY category, battery_type;

-- Reporting view for Tableau (optional, handles NULLs)
CREATE OR REPLACE VIEW v_ev_dashboard AS
SELECT *, COALESCE(annual_sales_units,0) AS sales_clean FROM ev_vehicles;
