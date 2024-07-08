import os
import pandas as pd
import duckdb
from sqlmesh import Context

def print_database_info(conn):
    print("\nDatabase Information:")
    schemas = conn.execute("SELECT schema_name FROM information_schema.schemata").fetchall()
    print("Schemas:", [schema[0] for schema in schemas])
    
    for schema in schemas:
        tables = conn.execute(f"SELECT table_name FROM information_schema.tables WHERE table_schema = '{schema[0]}'").fetchall()
        print(f"Tables in {schema[0]} schema:", [table[0] for table in tables])

try:
    # Set the environment variable for SQLMesh
    os.environ['SQLMESH_ENV'] = 'dev'

    # Create SQLMesh context
    context = Context()

    # Force rebuild (specify the environment name)
    context.invalidate_environment('dev')

    # Create and apply plan
    plan = context.plan()
    context.apply(plan)

    print("Plan applied successfully.")
    print("Checking results...")

    # Connect to DuckDB
    conn = duckdb.connect('db.db')

    # Print database information
    print_database_info(conn)

    # Function to execute query and return results as DataFrame
    def run_query(query):
        try:
            return conn.execute(query).df()
        except Exception as e:
            print(f"Error executing query '{query}': {str(e)}")
            return pd.DataFrame()

    # Query the models and audits
    print("\nQuerying models and audits:")
    
    raw_df = run_query('SELECT * FROM default.raw_data_model')
    print("\nRaw Data Model:")
    print(raw_df)
    
    transformed_df = run_query('SELECT * FROM default.transformed_data_model')
    print("\nTransformed Data Model:")
    print(transformed_df)
    
    raw_audit_df = run_query('SELECT * FROM main.raw_data_model_audit')
    print("\nRaw Data Model Audit:")
    print(raw_audit_df)
    
    transformed_audit_df = run_query('SELECT * FROM main.transformed_data_model_audit')
    print("\nTransformed Data Model Audit:")
    print(transformed_audit_df)

    print("\nPipeline setup and audits complete.")

    # Close the connection
    conn.close()

except Exception as e:
    print(f"An error occurred: {str(e)}")
    
    # If there's an error, let's print more details about the context
    try:
        print("\nAvailable environments:")
        print(context.environments)
        print("\nCurrent environment:")
        print(context.environment)  
    except:
        print("Unable to print context details")