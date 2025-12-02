import pandas as pd

df = pd.read_csv("output.csv")
print("columns: ", list(df.columns))
print("rows: ", df.shape[0])