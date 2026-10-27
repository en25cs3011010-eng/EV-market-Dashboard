# Tableau Steps — EV Market Dashboard (exact field names from your dataset)

Data: `ev_market_clean.csv` (299,999 rows = train + test merged, 1 duplicate vehicle_id removed) or the MySQL table `ev_vehicles` / view `v_ev_dashboard`.
Connect: Tableau → Connect → MySQL (or Text file) → drag `ev_vehicles` in → choose **Extract**.
Set `manufacturing_country` → Geographic Role → Country/Region.

## Calculated fields (Analysis → Create Calculated Field)
1. **Total Sales** = `SUM([annual_sales_units])`
2. **Market Share %** = `SUM([annual_sales_units]) / TOTAL(SUM([annual_sales_units]))`
3. **Avg Range** = `AVG([range_km])`
4. **Avg Rating** = `AVG([customer_rating])`
5. **Rating Band** = `IF [customer_rating]>=4.5 THEN "Excellent" ELSEIF [customer_rating]>=4 THEN "Good" ELSEIF [customer_rating]>=3 THEN "Average" ELSE "Poor" END`
6. **Sales YoY %** = `(SUM([annual_sales_units]) - LOOKUP(SUM([annual_sales_units]),-1)) / ABS(LOOKUP(SUM([annual_sales_units]),-1))` (Edit table calc → compute along *model_year*)
7. **Price Segment** = `IF [price_usd]<20000 THEN "Budget" ELSEIF [price_usd]<60000 THEN "Mid" ELSE "Premium" END`
8. **Range per kWh** = `SUM([range_km])/SUM([battery_capacity_kwh])`
9. **Battery Type Share** = `SUM([annual_sales_units]) / TOTAL(SUM([annual_sales_units]))` (compute using *battery_type*)

Note: ~1% of `annual_sales_units` and ~2% of `customer_rating` are blank. Tableau ignores NULLs in SUM/AVG, so no action is needed. Also, the max sales value is ~1.07M vs a median of ~3.9K, so expect outliers in the scatter.

## 9 visualizations (one sheet each, name them V1…V9)

**V1 Sales by Category** (Emily)
Rows: `category`; Columns: `Total Sales`; sort descending; Color: `category`; Label on. Answers which categories contribute the most (Two-Wheeler Scooter leads, then Sedan, Hatchback, Compact SUV).

**V2 Top 10 Manufacturers** (Emily, David)
Rows: `manufacturer`; Columns: `Total Sales`. Right-click `manufacturer` → Filter → Top → By field → Top 10 by Sum of `annual_sales_units`. Sort descending. (There are 200 manufacturers, so the top-10 filter is essential.)

**V3 Manufacturer Market Share** (David)
Mark: Treemap. `manufacturer` → Detail + Label, `Total Sales` → Size, `Market Share %` → Color. Apply the same Top 10 filter, or use a Top 20 parameter. Shares are tiny since there are 200 manufacturers (the top one, AmpereWorks, has only about 0.6%), so label with two decimals, e.g. 0.00%.

**V4 Battery Technology Adoption** (all)
Mark: Pie. `battery_type` → Color, `Total Sales` → Angle, `Battery Type Share` → Label. For a donut, use a dual-axis with a white circle. Covers LFP, NMC, NCA, Sodium-Ion and Solid-State.

**V5 Driving Range by Category** (Emily, Sarah)
Columns: `category`; Rows: `Avg Range`; Color: `battery_type`. Add a reference line (Analytics → Average Line). Sort by Avg Range.

**V6 Customer Satisfaction Heatmap** (Emily, Sarah)
Mark: Square. Rows: `category`; Columns: `battery_type`; Color + Label: `Avg Rating`. Use a diverging palette centered on 4.1 (the dataset mean).

**V7 Manufacturing Country Map** (David, Sarah)
Double-click `manufacturing_country` → Filled Map. Color: `Total Sales`; Tooltip: `COUNTD(manufacturer)`, `Avg Rating`. There are 10 countries: India, South Korea, UK, USA, China, Germany, France, Sweden, Vietnam, Japan.

**V8 Sales Trend and Growth by Category** (Emily — high-growth segments)
Columns: `model_year` (Continuous/Discrete); Rows: `Total Sales`; Color: `category`. Analytics → Trend Line. Put `Sales YoY %` in the Tooltip. Years cover 2018–2026.

**V9 Battery Capacity vs Range** (Sarah)
Columns: `AVG(battery_capacity_kwh)`; Rows: `AVG(range_km)`; Detail: `manufacturer` or `category`; Color: `battery_type`; Size: `Total Sales`. Analytics → Trend Line. (Aggregate it; plotting 300K raw points will be slow.)

## Dashboard (Dashboard → New Dashboard)
- Size: **Automatic** (responsive). Build in a vertical container: KPI row (Total Sales, Avg Range, Avg Rating as BAN text sheets) → row 1: V1, V2, V3 → row 2: V4, V5, V6 → row 3: V7, V8, V9.
- Filters (Show Filter → Apply to Worksheets → All Using This Data Source): `model_year`, `category`, `market_region`, `battery_type`, `manufacturing_country`, `Price Segment`, `Rating Band`.
- Click the funnel icon (Use as Filter) on V1, V3, V4 and V7.
- Add a Highlight action on `battery_type`.
- Device Layouts → add Phone.

## Story (Story → New Story), 4 scenes
1. **Market Overview (Emily):** V1, V2, V8
2. **Competitive Landscape (David):** V3, V7, V4
3. **Tech and Satisfaction (Sarah):** V5, V6, V9
4. **Recommendations:** full dashboard plus caption text

## Performance testing
Help → Settings and Performance → Start Performance Recording → interact with the dashboard → Stop → screenshot. Record: 299,999 rows, 9 visualizations, 9 calculated fields, 7 filters.

## Publish & Flask
File → Save to Tableau Public → open your viz → Share → copy the Embed Code. Paste it into `flask_app/templates/dashboard.html` (and the story's embed code into `story.html`). Then:
```
cd flask_app && pip install -r requirements.txt && python app.py
```
Open http://127.0.0.1:5000. For the project demo, show `/` and `/story`.
