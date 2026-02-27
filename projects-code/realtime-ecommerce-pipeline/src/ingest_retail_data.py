import pandas as pd
import os

# Professional path management
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
OUTPUT_FILE = os.path.join(DATA_DIR, "online_retail.csv")

def download_data():
    if not os.path.exists(DATA_DIR):
        os.makedirs(DATA_DIR)
    
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/00352/Online%20Retail.xlsx"
    print("Downloading UK Retail Dataset... (approx. 50MB)")
    
    # Requires: pip install pandas openpyxl
    df = pd.read_excel(url)
    df.to_csv(OUTPUT_FILE, index=False)
    print(f"Success! Data saved to: {OUTPUT_FILE}")
    print(f"Total Transactions Loaded: {len(df)}")

if __name__ == "__main__":
    download_data()