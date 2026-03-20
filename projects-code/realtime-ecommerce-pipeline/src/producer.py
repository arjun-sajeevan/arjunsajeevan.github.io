import pandas as pd
from kafka import KafkaProducer
import json
import time

# 1. THE CONNECTION: Tell the script where the "Post Office" is
# We use localhost:9092 because that is the port we opened in Docker
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda x: json.dumps(x).encode('utf-8')
)

# 2. THE DATA SOURCE: Load our cleaned CSV
df = pd.read_csv('data/online_retail.csv')

print("Starting the stream... Press Ctrl+C to stop.")

# 3. THE STREAMING LOOP: Send rows one by one
# We convert each row to a dictionary (JSON) because Kafka loves JSON
for index, row in df.iterrows():
    transaction = row.to_dict()
    
    # Send the "letter" to the "retail-transactions" mailbox
    producer.send('retail-transactions', value=transaction)
    
    print(f"Sent: Invoice {transaction['InvoiceNo']} - {transaction['Description']}")
    
    # Wait for 1 second so we can actually see the stream moving
    time.sleep(1)