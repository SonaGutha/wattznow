# import pandas as pd
# from constants import *
#
#
# df = None
#
#
# def load_and_prepare_data(filepath=data_path):
#     global df
#     df = pd.read_csv(filepath)
#     df.columns = df.columns.str.replace(' ', '_')
#     df = df.drop([DATA_SOURCE, DATA_ESTIMATED, DATA_ESTIMATION_METHOD], axis=1, errors='ignore')
#     df = df.drop([COUNTRY, ZONE_NAME, ZONE_ID], axis=1, errors='ignore')
#     df[DATETIME_COL] = pd.to_datetime(df[DATETIME_COL])
#
#     df[DATE] = df[DATETIME_COL].dt.date
#     df[TIME] = df[DATETIME_COL].dt.time
#
#     df.rename(columns={
#         DATETIME_COL: DATETIME,
#         DIRECT_CI_COL: DIRECT_CI,
#         LIFECYCLE_CI_COL: LIFECYCLE_CI,
#         CFE_COL: CFE_PERCENT,
#         RE_COL: RE_PERCENT,
#     }, inplace=True)
#
#     return df
#
#
# def get_highest_cfe_window(target_date, start_hour=8, end_hour=20, window=3):
#     global df
#     df[DATETIME] = pd.to_datetime(df[DATETIME])
#
#     mask = (df[DATETIME].dt.date == pd.to_datetime(target_date).date()) & \
#            (df[DATETIME].dt.hour >= start_hour) & (df[DATETIME].dt.hour <= end_hour)
#
#     daily_df = df.loc[mask].reset_index(drop=True)
#     daily_df["CFE_3hr_avg"] = daily_df[CFE_PERCENT].rolling(window=window).mean()
#
#     if daily_df["CFE_3hr_avg"].isnull().all():
#         return pd.DataFrame()
#
#     max_idx = daily_df["CFE_3hr_avg"].idxmax()
#     start_idx = max(max_idx - window + 1, 0)
#     return daily_df.loc[start_idx:max_idx]
