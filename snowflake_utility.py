"""SNOWFLAKE """

import snowflake.connector as conn
from snowflake.connector.errors import *
import json


class SnowflakeCursor:

    def __init__(self, conn_params):
        self.conn = conn.connect(user=conn_params['snowflake_user'],
                                 password=conn_params['password'],
                                 account=conn_params['account'],
                                 warehouse=conn_params['warehouse'],
                                 authenticator=conn_params['authenticator']
                                 )
        self.cur = self.conn.cursor()

    def execute(self, sql):
        """Execute an sql statement"""
        try:
            self.cur.execute(sql)
        except Exception as exc:
            self._raise_execution_exception(exc)

    def execute_block(self, sql_commands):
        """Execute a list of sql statements in a transaction block"""
        self.begin()
        for sql in sql_commands:
            self.execute(sql)
        self.commit()

    def rowcount(self):
        """Get the row count of the previously executed statement from the cursor"""
        return self.cur.rowcount

    def begin(self):
        """Begin a transaction"""
        print("Beginning Transaction")
        self.cur.execute("BEGIN")

    def commit(self):
        """Commit the transaction"""
        print("Committing transaction")
        self.cur.execute("COMMIT")

    def rollback(self):
        """Rollback the transaction"""
        print("Rolling back transaction")
        self.cur.execute('ROLLBACK;')

    def close(self):
        """Close the connection"""
        print("Closing connection")
        self.conn.close()

    def _raise_execution_exception(self, exc):
        """Raise the exception, rollback the current transaction, and close the connection"""
        print("[ERROR] - Query execution Failed")
        try:
            self.rollback()
        except Exception:
            pass
        self.close()
        raise exc

    def fetch_single_element(self):
        """Return element one from row one
        This is used for things like `SELECT COUNT(*)`
        where only a single value is expected.
        This method should not be confused with the common DB-API function `fetchone`.
        """
        results = self.cur.fetchone()
        if results:
            return results[0]
        else:
            raise ValueError("Could not fetch single element from results: {}".format(results))

    def fetchall(self):
        """Fetch all results from the cursor"""
        return self.cur.fetchall()



