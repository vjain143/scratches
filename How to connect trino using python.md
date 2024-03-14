import trino

# Define connection parameters
host = 'localhost'  # Trino server hostname or IP address
port = 8080  # Trino server port
user = 'your_username'  # Trino username
catalog = 'hive'  # Catalog name (e.g., hive, mysql)
schema = 'your_schema'  # Schema name (e.g., default)

# Create a connection to Trino
conn = trino.dbapi.connect(
    host=host,
    port=port,
    user=user,
    catalog=catalog,
    schema=schema
)

# Create a cursor
cur = conn.cursor()

# Execute a query
query = 'SELECT * FROM your_table'
cur.execute(query)

# Fetch and print results
for row in cur.fetchall():
    print(row)

# Close cursor and connection
cur.close()
conn.close()
