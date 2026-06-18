import csv
from datetime import datetime

def clean_price(price_str):
    if not price_str:
        return None
    # Strip spaces and dollar signs
    clean_str = price_str.strip().replace("$", "")
    try:
        return float(clean_str)
    except ValueError:
        return None

def parse_date(date_str):
    if not date_str:
        return None
    clean_str = date_str.strip()
    for fmt in ["%Y-%m-%d", "%Y/%m/%d"]:
        try:
            return datetime.strptime(clean_str, fmt).strftime("%Y-%m-%d")
        except ValueError:
            continue
    return None

def main():
    input_file = "raw_sales.csv"
    output_file = "cleaned_sales.csv"
    
    seen_transactions = set()
    
    # Audit counters
    total_processed = 0
    exported = 0
    rejected_missing_txn = 0
    rejected_duplicates = 0
    rejected_date = 0
    rejected_price = 0
    rejected_qty = 0
    rejected_product = 0

    try:
        with open(input_file, mode="r", encoding="utf-8") as infile, \
             open(output_file, mode="w", encoding="utf-8", newline="") as outfile:
            
            reader = csv.DictReader(infile)
            fieldnames = ["transaction_id", "date", "product_id", "quantity", "price"]
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()

            for row in reader:
                total_processed += 1
                
                txn_id = row.get("transaction_id", "").strip()
                if not txn_id:
                    rejected_missing_txn += 1
                    continue
                    
                if txn_id in seen_transactions:
                    rejected_duplicates += 1
                    continue
                seen_transactions.add(txn_id)

                date_val = parse_date(row.get("date", ""))
                if not date_val:
                    rejected_date += 1
                    continue

                price_val = clean_price(row.get("price", ""))
                if price_val is None:
                    rejected_price += 1
                    continue

                qty_str = row.get("quantity", "").strip()
                try:
                    qty_val = int(qty_str)
                except ValueError:
                    rejected_qty += 1
                    continue

                product_id = row.get("product_id", "").strip()
                if not product_id:
                    rejected_product += 1
                    continue
                
                # Write cleaned record
                writer.writerow({
                    "transaction_id": txn_id,
                    "date": date_val,
                    "product_id": product_id,
                    "quantity": qty_val,
                    "price": price_val
                })
                exported += 1

        print("--- Pipeline Audit Report ---")
        print(f"📥 Total Raw Records Processed: {total_processed}")
        print(f"📤 Cleaned Records Exported:    {exported}")
        print("❌ Rejected Records Details:")
        print(f"   - Missing TXN ID:         {rejected_missing_txn}")
        print(f"   - Duplicates:             {rejected_duplicates}")
        print(f"   - Invalid/Missing Date:   {rejected_date}")
        print(f"   - Invalid/Missing Price:  {rejected_price}")
        print(f"   - Invalid/Missing Qty:    {rejected_qty}")
        print(f"   - Missing Product ID:     {rejected_product}")
        print("-----------------------------")
        print(f"\nSuccess! Cleaned data saved to {output_file}")

    except FileNotFoundError:
        print(f"Error: {input_file} not found. Please make sure the sample file is in the same directory.")

if __name__ == "__main__":
    main()
