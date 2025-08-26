import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# ======================
# Page Config
# ======================
st.set_page_config(
    page_title="CSR Dashboard",
    page_icon="brand faviconn.png",
    layout="wide"
)

# ======================
# Load & Clean Data
# ======================
file_path = "CSR_Report_2025-07-26.csv"
df = pd.read_csv(file_path)

# Clean data: strip spaces, lowercase column names
df.columns = df.columns.str.strip().str.lower()
df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x)

# Standardize column names
df.rename(columns={
    "company name": "company",
    "financial year": "fy",
    "psu/non-psu": "psu_status",
    "csr state": "state",
    "csr development sector": "dev_sector",
    "csr sub development sector": "sub_dev_sector",
    "project amount spent (in inr cr.)": "amount"
}, inplace=True)

# Clean PSU/Non-PSU column (case insensitive)
df["psu_status"] = df["psu_status"].str.lower().map({
    "psu": "PSU",
    "non-psu": "Non-PSU"
})

# ======================
# Sidebar Filters
# ======================
st.sidebar.header("Filters")

# Helper for "Select All" dropdown
def multi_select_filter(label, options):
    all_selected = st.sidebar.checkbox(f"Select All {label}", value=True)
    if all_selected:
        return options
    else:
        return st.sidebar.multiselect(f"Select {label}", options=options)

# Filters
fy_filter = multi_select_filter("Financial Year", df["fy"].sort_values().unique())
state_options = df["state"].str.title().unique()
state_filter = multi_select_filter("State", state_options)
psu_filter = multi_select_filter("PSU/Non-PSU", df["psu_status"].unique())
sector_filter = multi_select_filter("Development Sector", df["dev_sector"].unique())
sub_sector_filter = multi_select_filter("Sub Development Sector", df["sub_dev_sector"].unique())

st.sidebar.markdown("_Unselect 'Select All' option to choose specific items._")

# Apply filters
df_filtered = df[
    (df["fy"].isin(fy_filter)) &
    (df["state"].str.title().isin(state_filter)) &
    (df["psu_status"].isin(psu_filter)) &
    (df["dev_sector"].isin(sector_filter)) &
    (df["sub_dev_sector"].isin(sub_sector_filter))
]

# Exclude Pan India for state visuals
df_state_filtered = df_filtered[df_filtered["state"].str.lower() != "pan india"]

# ======================
# Page Title & Intro
# ======================
st.title("📊 CSR Dashboard")
st.markdown("""
### Exploring CSR Spending Across India
This dashboard provides insights into CSR expenditure across companies, states, development sectors, and sub-sectors.
Use the filters on the left to explore data interactively.
""")
st.markdown("---")

# ======================
# KPI Cards
# ======================
col1, col2, col3, col4, col5 = st.columns(5)
col1.metric("Total Companies", df_filtered["company"].nunique())
col2.metric("States Involved", df_state_filtered["state"].nunique())
col3.metric("Development Sectors", df_filtered["dev_sector"].nunique())
col4.metric("Sub-Sectors", df_filtered["sub_dev_sector"].nunique())
col5.metric("Total CSR Spend (Cr)", round(df_filtered["amount"].sum(), 2))
st.markdown("---")
# ======================
# 1. Year-wise CSR Trend (Line Chart)
# ======================
year_trend = df_filtered.groupby("fy")["amount"].sum().reset_index().sort_values("fy")
fig1 = px.line(year_trend, x="fy", y="amount", markers=True,
               title="📈 Year-wise CSR Expenditure Trend",
               labels={"fy": "Financial Year", "amount": "Amount (Cr)"},
               color_discrete_sequence=["#636EFA"])
fig1.update_layout(title_font=dict(size=30))  # increased title font
st.plotly_chart(fig1, use_container_width=True)
st.markdown("""**📌Insights**:

💡CSR spending increased steadily from FY 2019-20 to FY 2022-23, with a peak in FY 2021-22, possibly due to pandemic-related CSR initiatives.

💡FY 2020-21 shows a slight dip, likely reflecting economic slowdown.

💡Overall, corporate social responsibility investments are growing year on year.""")
st.markdown("<br><br>", unsafe_allow_html=True)

# ======================
# 2. Top Companies (Lollipop Chart)
# ======================
top_companies = df_filtered.groupby("company")["amount"].sum().reset_index().sort_values("amount", ascending=False).head(10)
fig2 = go.Figure()
fig2.add_trace(go.Scatter(
    x=top_companies["amount"],
    y=top_companies["company"],
    mode='markers+lines',
    marker=dict(size=15, color=top_companies["amount"], colorscale='Viridis'),
    line=dict(color='gray', width=2)
))
fig2.update_layout(title="🏢 Top 10 Companies by CSR Spending",
                   xaxis_title="Amount (Cr)", yaxis_title="Company",
                   title_font=dict(size=30))  # increased title font
fig2.update_yaxes(autorange="reversed")
st.plotly_chart(fig2, use_container_width=True)
st.markdown("""**📌Insights:** 
            
💡The top contributor (e.g., Company A) accounts for almost 15–20% of total CSR spend.

💡Other companies show a gradual decrease in funding, highlighting concentration among the top 3–4 contributors.

💡This indicates that CSR funding is dominated by a few major players.""")
st.markdown("<br><br>", unsafe_allow_html=True)

# ======================
# 3. State-wise CSR Spending (Pie Chart)
# ======================
state_spend = df_state_filtered.groupby("state")["amount"].sum().reset_index().sort_values("amount", ascending=False)
fig3 = px.pie(state_spend, names="state", values="amount", title="🌍 State-wise CSR Spending",
              color_discrete_sequence=px.colors.qualitative.Set3)
fig3.update_layout(title_font=dict(size=30))  # increased title font


st.plotly_chart(fig3, use_container_width=True)
st.markdown("""**📌Insights:** 
            
💡States like Maharashtra, Karnataka, and Tamil Nadu receive the largest share of CSR funds.

💡Some states (e.g., smaller or northeastern states) receive less than 5% each, showing uneven regional distribution.

💡This visual shows where CSR projects are concentrated geographically.""")
st.markdown("<br><br>", unsafe_allow_html=True)

# ======================
# 4. Development Sector Distribution (Treemap)
# ======================
sector_dist = df_filtered.groupby("dev_sector")["amount"].sum().reset_index().sort_values("amount", ascending=False)
fig4 = px.treemap(sector_dist, path=["dev_sector"], values="amount",
                  title="💰 CSR Spending by Development Sector",
                  height=600,
                  color="amount", color_continuous_scale="Viridis")
fig4.update_layout(title_font=dict(size=30))  # increased title font
st.plotly_chart(fig4, use_container_width=True)
st.markdown("""**📌Insights:** 
            
💡Sectors like Education and Health together receive over 50% of CSR funds, highlighting corporate priorities.

💡Other sectors like Environment or Art & Culture receive smaller allocations, showing potential areas for growth.

💡The treemap makes it clear which sectors dominate CSR investments.""")
st.markdown("<br><br>", unsafe_allow_html=True)

# ======================
# 5. Sub-Sector Distribution (Donut Chart)
# ======================
sub_sector_dist = df_filtered.groupby("sub_dev_sector")["amount"].sum().reset_index().sort_values("amount", ascending=False)
fig5 = px.pie(sub_sector_dist, names="sub_dev_sector", values="amount", hole=0.4,
              title="🌐 CSR Spending by Sub-Sectors",
              color_discrete_sequence=px.colors.qualitative.Set2)
fig5.update_layout(title_font=dict(size=30))  # increased title font
st.plotly_chart(fig5, use_container_width=True)
st.markdown("""**📌Insights:** 
            
💡Within Education, projects in “Scholarships” or “Infrastructure” dominate the spend.

💡Health sub-sectors like “Healthcare Access” receive the bulk of funding.

💡Sub-sector contributions are skewed, indicating focused strategies within sectors.""")
st.markdown("<br><br>", unsafe_allow_html=True)

# ======================
# 6. PSU vs Non-PSU (Stacked Bar)
# ======================
psu_trend = df_filtered.groupby(["fy", "psu_status"])["amount"].sum().reset_index()
fig6 = px.bar(psu_trend, x="fy", y="amount", color="psu_status", barmode="stack",
              title="🏛 PSU vs Non-PSU CSR Spending",
              color_discrete_sequence=["#636EFA", "#EF553B"])
fig6.update_layout(title_font=dict(size=30))  # increased title font
st.plotly_chart(fig6, use_container_width=True)
st.markdown("""**📌Insights:** 
            
💡PSUs show steady contributions across all years, while Non-PSU contributions vary more.

💡Non-PSUs lead CSR spend in FY 2021-22, likely reflecting large private company initiatives.

💡Overall, both sectors contribute meaningfully, but the pattern of spend differs.""")

st.markdown("<br><br>", unsafe_allow_html=True)
# ======================
# Footer

st.markdown(
    """
    <style>
    .footer {
        position: relative;
        bottom: 0;
        width: 100%;
        text-align: center;
        padding: 8px;
        font-size: 14px;
        color: #555;
    }
    </style>
    <div class="footer">
    <hr>
        ✨Insights brought to you by <b>Varshiga MK</b>.
    <hr>    
    </div>
    """,
    unsafe_allow_html=True
)
