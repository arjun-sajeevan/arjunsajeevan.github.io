# Real-Time E-Commerce Data Pipeline: Local Streaming Architecture

## 📖 Project Overview

This project simulates a real-time, event-driven data pipeline for an e-commerce platform. It transforms static historical data into a live stream, buffers the events using a containerized message broker, and processes the stream using a distributed analytics engine.

The goal of this phase is to establish a robust, decoupled local architecture that mirrors enterprise-grade production environments, managing infrastructure, network streaming, and JVM-level dependency alignments.

---

## 🏗️ Architecture & Technology Stack

| Layer | Technology | Role |
|---|---|---|
| **Source** | `online_retail.csv` | Simulates a transactional database |
| **Producer** | Python | Edge-device simulator — reads CSV, serializes rows to JSON, and publishes real-time events |
| **Message Broker** | Apache Kafka & Zookeeper (Docker) | Buffers and routes events, manages backpressure, decouples ingestion from analytics |
| **Consumer** | PySpark Structured Streaming | Analytical brain — subscribes to Kafka topic, applies strict schema, outputs live micro-batches |

---

## ⚙️ Prerequisites & Environment Setup

To run this pipeline locally, you will need:

- **Docker Desktop** — for containerized infrastructure
- **Python 3.9+**
- **Java 17 (JDK)** — crucial for PySpark 3.5.0 compatibility

### ⚠️ Dependency Alignment Note: Java & Scala

Data Engineering often requires strict version alignment across the JVM. This project uses **Spark 3.5.0**, which requires **Scala 2.13**. To prevent `NoSuchMethodError` (specifically `WrappedArray` conflicts) or `[JAVA_GATEWAY_EXITED]` errors, ensure your local machine's `JAVA_HOME` is strictly mapped to **Java 17** before running the consumer.

---

## 🚀 Step-by-Step Execution Guide

### Step 1: Spin Up the Infrastructure (Docker)

Docker keeps the Kafka environment isolated and reproducible. Navigate to the project root and start the cluster in detached mode:
```bash
docker-compose up -d
```

Verify the containers (`kafka-1` and `zookeeper-1`) are running:
```bash
docker ps
```

---

### Step 2: Create the Kafka Topic

Create the topic that acts as the "mailbox" between producer and consumer:
```bash
# Enter the Kafka container
docker exec -it realtime-ecommerce-pipeline-kafka-1 /bin/bash

# Create the topic
kafka-topics --create \
  --topic retail-transactions \
  --bootstrap-server localhost:9092 \
  --partitions 1 \
  --replication-factor 1

# Exit the container
exit
```

---

### Step 3: Configure the Local Environment

Install the required Python libraries:
```bash
pip3 install kafka-python pandas pyspark
```

**Force your terminal session to use Java 17** (macOS with Homebrew):
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
export PATH=$JAVA_HOME/bin:$PATH
```

---

### Step 4: Start the PySpark Consumer

Start the analytical engine first so it is ready to receive data. In **Terminal 1**, run:
```bash
python3 src/consumer.py
```

> **Note:** On the first run, Spark will download the required `spark-sql-kafka` and `kafka-clients` JAR files automatically. Wait until the console prints:
> ```
> PySpark is waiting for the stream...
> ```

---

### Step 5: Start the Python Producer

With the consumer listening, open **Terminal 2** and start ingestion:
```bash
python3 src/producer.py
```

---

## 🎉 Result

In **Terminal 1**, PySpark will continuously process and print structured micro-batches of JSON events as they arrive from Kafka in real time.