# carbon emission data
data_path = "data/US-MIDW-MISO_2024_hourly.csv"

# Raw column names as they appear in the CSV
DATETIME_COL = "Datetime_(UTC)"
DIRECT_CI_COL = "Carbon_intensity_gCO₂eq/kWh_(direct)"
LIFECYCLE_CI_COL = "Carbon_intensity_gCO₂eq/kWh_(Life_cycle)"
CFE_COL = "Carbon-free_energy_percentage_(CFE%)"
RE_COL = "Renewable_energy_percentage_(RE%)"
DATA_SOURCE = "Data_source"
DATA_ESTIMATED = 'Data_estimated'
DATA_ESTIMATION_METHOD = 'Data_estimation_method'
COUNTRY = 'Country'
ZONE_NAME = 'Zone_name'
ZONE_ID = 'Zone_id'


# Rename
DATETIME = "Datetime"
DIRECT_CI = "Direct_CI"
LIFECYCLE_CI = "Lifecycle_CI"
CFE_PERCENT = "CFE_Percent"
RE_PERCENT = "RE_Percent"
DATE = 'Date'
TIME = 'Time'


CFE_AVG = "CFE_avg"
DIRECT_CI_AVG = "direct_CI_avg"


#request params defaults
DEFAULT_DATE = '2024-01-01'
DEFAULT_START_TIME = 0
DEFAULT_END_TIME = 23
DEFAULT_WINDOW = 1