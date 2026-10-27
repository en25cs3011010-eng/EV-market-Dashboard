# EV Market Analytics Dashboard

An interactive Tableau dashboard and story on the global electric vehicle market, backed by a MySQL database and embedded in a Flask web app.

## Scenarios
- **Emily Johnson, EV Market Strategy Director:** which vehicle categories drive annual sales, who the leading manufacturers are, and how customer satisfaction, battery adoption, driving range and high-growth segments compare.
- **David Chen, Automotive BI Manager:** manufacturer market share, sales performance, battery technology distribution, manufacturing country analysis and customer ratings.
- **Dr. Sarah Williams, Sustainable Mobility Researcher:** battery technology comparison, range improvements, global manufacturing distribution and satisfaction by category.

## Tech stack
MySQL, Tableau (Desktop and Public), Python, Flask

## Dataset
EV market dataset (`ev_market_train.csv` and `ev_market_test.csv`) from Kaggle. Merged, with one duplicate vehicle ID removed, into 299,999 rows and 37 columns. The raw CSV is not stored in this repository because of its size. Place `ev_market_clean.csv` in the project folder to load it.

## Repository structure
```
flask_app/   Flask app that embeds the Tableau dashboard (/) and story (/story)
sql/         MySQL schema, load script, analysis queries and saved query results
docs/        Tableau build steps and screenshots
```

## How to run
1. **Database:** run `sql/schema_and_sql.sql` in MySQL (or load the CSV with `sql/load_to_mysql.py`).
2. **Tableau:** connect to the `ev_vehicles` table, then build the visualizations as described in `docs/TABLEAU_STEPS.md`.
3. **Web app:**
```
cd flask_app
pip install -r requirements.txt
python app.py
```
Open http://127.0.0.1:5000. Paste your Tableau Public embed codes into `templates/dashboard.html` and `templates/story.html`.

## Dashboard contents
Nine visualizations: sales by category, top 10 manufacturers, market share treemap, battery technology distribution, range by category, customer satisfaction heatmap, manufacturing country map, sales trend by category over years, and battery capacity vs range.

## Key findings
- Two-Wheeler Scooters lead sales (about 259.6M units), followed by Sedans, Hatchbacks and Compact SUVs.
- No manufacturer dominates: the top one holds only about 0.6% share across 200 manufacturers.
- NMC and LFP lead battery adoption; Solid-State has the lowest 5-year degradation (about 7.4% vs about 14% for NMC, NCA and Sodium-Ion).
- Production is spread evenly across 10 countries, with China slightly ahead.

## Links
- Tableau Public dashboard: _add link_
- Demo video: _add link_
