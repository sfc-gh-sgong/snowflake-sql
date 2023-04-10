import sys

import pandas as pd
from sqlninja import engine as sqlninja
from snowflake_utility import SnowflakeCursor


if __name__ == '__main__':

    df = pd.read_excel("Full Mapping for GA Looker-Snowflake.xlsx",'Full List - GA',header=None)
    print(df.columns)
    wh_list = df[4].tolist()

    for wh_name in wh_list:
        query = sqlninja.render("sql/warehouse.sql", wh_name=wh_name)
        print(query)
