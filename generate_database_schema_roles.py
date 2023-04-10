import sys

import pandas as pd
from sqlninja import engine as sqlninja
from snowflake_utility import SnowflakeCursor


if __name__ == '__main__':

    company_name= sys.argv[1]
    env_name = sys.argv[2]
    schema_name = sys.argv[3]
    db_region = sys.argv[4]

    query = sqlninja.render("sql/rbac.sql", env_name=env_name,schema_name=schema_name,company_name=company_name,db_region=db_region )
    print(query)