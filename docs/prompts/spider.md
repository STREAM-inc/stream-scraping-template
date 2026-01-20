A. 詳細ページへの導線URLパターン

B. 詳細ページURLパターン

C. 詳細ページのデータの取り方（項目ごとの仕様）

<生成されたspiderの初期コード sitename/spiders/domain_s.py>

CrawlSpiderを使って簡潔にじっそうしてください。

詳細ページの判定はLinkExtractorにおいて絶対パスを使用してください。 

カラム名は必ず日本語でお願いします。 

データには取得日時、取得URLを必ず先頭に含めてください

環境変数CRAWL_DEBUGを確認して、Falseであったら 

先頭で from crawlab import save_item 取得データにたいして save_item(item)