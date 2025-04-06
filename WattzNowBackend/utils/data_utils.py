import pandas as pd
from datetime import timedelta

from utils.constants import *

df = None

def safe_replace_year(dt, year):
    try:
        return dt.replace(year=year)
    except ValueError:
        # Handle Feb 29 → Feb 28 in non-leap years
        if dt.month == 2 and dt.day == 29:
            return dt.replace(year=year, day=28)
        raise

def load_and_prepare_data(filepath=data_path):
    global df
    df = pd.read_csv(filepath)
    df.columns = df.columns.str.replace(' ', '_')
    df = df.drop([DATA_SOURCE, DATA_ESTIMATED, DATA_ESTIMATION_METHOD], axis=1, errors='ignore')
    df = df.drop([COUNTRY, ZONE_NAME, ZONE_ID], axis=1, errors='ignore')
    df[DATETIME_COL] = pd.to_datetime(df[DATETIME_COL])
    df[DATETIME_COL] = df[DATETIME_COL].apply(lambda dt: safe_replace_year(dt, 2025))

    df[DATE] = df[DATETIME_COL].dt.date
    df[TIME] = df[DATETIME_COL].dt.time

    df.rename(columns={
        DATETIME_COL: DATETIME,
        DIRECT_CI_COL: DIRECT_CI,
        LIFECYCLE_CI_COL: LIFECYCLE_CI,
        CFE_COL: CFE_PERCENT,
        RE_COL: RE_PERCENT,
    }, inplace=True)

    return df


def get_highest_cfe_window(target_date, start_hour=0, end_hour=23, window=1):
    global df
    df[DATETIME] = pd.to_datetime(df[DATETIME])

    mask = (df[DATETIME].dt.date == pd.to_datetime(target_date).date()) & \
           (df[DATETIME].dt.hour >= start_hour) & (df[DATETIME].dt.hour <= end_hour)

    daily_df = df.loc[mask].reset_index(drop=True)
    daily_df["CFE_avg"] = daily_df[CFE_PERCENT].rolling(window=window).mean()

    if daily_df["CFE_avg"].isnull().all():
        return pd.DataFrame()

    max_idx = daily_df["CFE_avg"].idxmax()
    start_idx = max(max_idx - window + 1, 0)
    return daily_df.loc[start_idx:max_idx]


def get_lowest_direct_ci_window(start_date, end_date, start_time, end_time, window=1):
    global df

    # Ensure inputs are proper date/time objects
    start_date = pd.to_datetime(start_date).date()
    end_date = pd.to_datetime(end_date).date()

    # Filter rows by date range and time window
    mask = (
            (df[DATETIME].dt.date >= start_date) &
            (df[DATETIME].dt.date <= end_date) &
            (df[DATETIME].dt.time >= start_time) &
            (df[DATETIME].dt.time < end_time)
    )

    daily_df = df.loc[mask].reset_index(drop=True)

    # Compute rolling average of direct CI
    daily_df[DIRECT_CI_AVG] = daily_df[DIRECT_CI].rolling(window=window).mean()

    # Collect suggestions
    suggestions = []
    for i in range(window - 1, len(daily_df)):
        window_df = daily_df.iloc[i - window + 1:i + 1]
        avg_value = window_df[DIRECT_CI_AVG].mean()
        start_win = window_df.iloc[0][DATETIME]
        end_win = start_win + timedelta(hours=window)

        suggestions.append({
            "start": start_win.isoformat(),
            "end": end_win.isoformat(),
            "avg_direct_ci": round(avg_value, 2)
        })

    return sorted(suggestions, key=lambda x: x["avg_direct_ci"])[:3]
