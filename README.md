# UK Railway Data Management & Forecasting

A complete end-to-end project for data cleaning, modeling, analysis, and forecasting in the UK railway sector. Built using SQL, Python, and Tableau, the project enables optimized decision-making based on real-world railway operational and ticketing data.

---

## 📌 Overview

This project was developed as part of the **Digital Egypt Pioneers Initiative (DEPI)** under the **Google Data Analytics Specialist Track**. It showcases the full pipeline from data ingestion to forecasting.

We transformed a flat dataset of UK railway transactions into a normalized relational database, performed advanced analysis, built interactive dashboards, and developed forecasting models for future operational planning.

---

## 🧰 Tools & Technologies

- **SQL** – Database design, normalization, querying
- **Python** – Data cleaning, preprocessing, forecasting
- **Tableau** – Dashboard creation and data visualization
- **Excel** – Initial exploration and data validation
- **Prophet & Random Forest** – Time series forecasting

---

## 📁 Project Structure

UK-Railway-Analysis/
├── dataset/ # Raw datasets
├── excel/ # Cleaned and transformed data in Excel files
├── sql/ # SQL scripts for database setup and queries
├── forecasting/ # Python notebooks for forecasting models
├── python/ # Python notebooks for data analysis
├── Tableau/ # Tableau dashboards and visualizations
├── PowerBI/ # Power BI dashboards and visualizations
├── presentation/ # PowerPoint file for final presentation
├── documentation/ # Final project documentation (docx/pdf)
└── README.md # Project overview and instructions

---

## 🧱 Data Engineering & Modeling

- **Validation**: Checked for nulls, duplicates, outliers, and formatting issues.
- **Cleaning**: Handled inconsistent values (e.g., "None" → "No Railcard"), fixed missing station names, standardized date/time formats.
- **Preprocessing**:
  - Created station and route codes.
  - Added new attributes (e.g., delay category, date types).
- **Normalization**: Split into 5 normalized tables:
  - `Stations`
  - `Routes`
  - `Journeys`
  - `Transactions`
  - `Calendar`
- **Schema & ERD**: Designed and implemented relational structure with foreign key integrity.

---

## 📊 Analysis Insights

### 🎟️ Passenger Behavior
- Most common ticket type: **Advance**
- 90%+ passengers choose **Standard Class**
- 58.5% of purchases made **online**
- 33.9% of passengers used a **Railcard**
- Top payment method: **Credit Card (60%)**

### 🚉 Journey & Railway Performance
- Total journeys: **19,871**
- On-time journeys: **18,019 (90.7%)**
- Delayed: **1,062**, Cancelled: **790**
- Average delay duration: **37 mins**
- Top delay reasons: **Weather Conditions**, **Staff Shortage**

### 🗺️ Routes & Stations
- 64 unique routes, 12 departure and 31 arrival stations
- Busiest departure: **Manchester Piccadilly**
- Busiest arrival: **Birmingham New Street**
- High-delay routes: **YRK–WKF, EUS–YRK, EDB–KGX** (100% delayed)

### 💰 Revenue & Sales
- Total revenue: **£741,921**
- Net revenue: **£703,219** after refunds
- Most profitable route: **KGX–YRK**
- Top ticket type revenue: **Advance (£293.6k)**

---

## 🔮 Forecasting Results (May 2024)

Modeling was performed using **Prophet** and **Random Forest Regressor** with evaluation metrics (MAPE, RMSE, MAE):

| Metric         | Forecast (May 2024) |
|----------------|---------------------|
| Bookings       | 8,147               |
| Journeys       | 5,100               |
| First Class    | 800 tickets         |
| Revenue        | £195,457            |

- **MAPE** ≈ 8–11% for most models
- Seasonality and holidays accounted for using calendar features

---

## 🧠 Recommendations

- **Peak hours**: Reduce headway, increase staff, use real-time alerts
- **Delayed routes**: Review infrastructure, staff levels, and communications
- **Refund policy**: Introduce tiered compensation for delays (e.g., 25%, 50%, 100%)
- **Holidays**: Maintain current frequency based on low booking trends

---

## 👨‍💼 Team & Supervision

**Supervised by:** Eng. Ahmed Samir  
**Team Members:**  
Ahmed Saad, George Ayad, Dina Sherif, Marwa Adel, Sara Samy, Hoda Gamal

---

## 📬 Contact

**Ahmed Saad El Fiky**  
📧 Email: [ah.saadfiky@gmail.com]  
🔗 LinkedIn: [linkedin.com/in/SaadFiky]  

---

## ✅ Project Status

- [x] Data cleaning & preprocessing  
- [x] Relational DB design & normalization  
- [x] Dashboards completed  
- [x] Forecasting models implemented  
- [x] Final documentation delivered  

---
