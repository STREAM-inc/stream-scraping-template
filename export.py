import json
import csv

input_file = "dump.txt"
output_file = "output.csv"

# JSON のキーを自動で集めて CSV のヘッダにする
rows = []
keys = set()

with open(input_file, "r", encoding="utf-8") as f:
    for line in f:
        if line.strip():
            obj = json.loads(line)
            rows.append(obj)
            keys.update(obj.keys())

keys = list(keys)

# CSV に書き込み
with open(output_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=keys)
    writer.writeheader()
    writer.writerows(rows)

print("Saved:", output_file)
