import time
import json
import random
import os
from datetime import datetime
from dotenv import load_dotenv
from azure.eventhub import EventHubProducerClient, EventData

# Load credentials from .env
load_dotenv()
CONNECTION_STR = os.getenv("EVENTHUB_CONNECTION_STR")
EVENTHUB_NAME = os.getenv("EVENTHUB_NAME")

def generate_smart_event():
    locations = ["Sydney-WH1", "Melbourne-WH2", "Brisbane-SiteA"]
    event_types = ["RODENT_DETECTED", "HEARTBEAT", "BATTERY_LOW", "SENSOR_CLEAN_REQ"]
    
    # Logic fix: only add pest_count if RODENT_DETECTED is the chosen type
    chosen_event = random.choices(event_types, weights=[10, 70, 10, 10])[0]
    
    return {
        "sensor_id": f"SNSR-{random.randint(1000, 9999)}",
        "timestamp": datetime.utcnow().isoformat(),
        "location": random.choice(locations),
        "event_type": chosen_event,
        "pest_count": random.randint(1, 3) if chosen_event == "RODENT_DETECTED" else 0,
        "battery_level": round(random.uniform(15.0, 99.0), 2)
    }

# Initialize Client
client = EventHubProducerClient.from_connection_string(CONNECTION_STR, eventhub_name=EVENTHUB_NAME)

print(f"Starting Flick SMART Simulation to {EVENTHUB_NAME}...")
try:
    while True:
        batch = client.create_batch()
        for _ in range(2): 
            event_data = generate_smart_event()
            batch.add(EventData(json.dumps(event_data)))
        
        client.send_batch(batch)
        print(f"Sent batch at {datetime.now().strftime('%H:%M:%S')}")
        time.sleep(1) 
except KeyboardInterrupt:
    print("Simulation stopped.")
finally:
    client.close()