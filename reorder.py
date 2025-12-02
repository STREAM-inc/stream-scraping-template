import pandas as pd

desired_order = [
    "取得日時",
    "取得URL",
    "名称",
    "TEL",
    "都道府県",
    "郵便番号",
    "住所",
    "業種",
    "法人番号",
    "代表者役職",
    "代表者",
    "資本金",
    "売上",
    "従業員数",
    "設立日",
    "事業内容",
    "FAX",
    "メール",
    "HP",
    "募集タイトル"
]

df = pd.read_csv("output.csv")

existing_cols = [col for col in desired_order if col in df.columns]

df[existing_cols].to_csv("output.csv", index=False, encoding="utf-8-sig")
