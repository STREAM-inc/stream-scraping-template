# ScrapyでPayPayグルメをスクレイピングするための事前整理（Step by Step）

このチュートリアルでは、requests + BeautifulSoupでスクレイピングできるサイトを、**Scrapyで再現**するために必要な「事前整理」をまとめます。  
（全体の流れは [ここ](/guide/scraping/) を参照）

---

## Step 1. 詳細ページで「取得したい項目」と「取り方」を確定する

### 1-1. 代表の詳細ページを1つ見て、取れる項目を列挙する
例：店舗ページ  
https://paypaygourmet.yahoo.co.jp/105355

店舗情報セクションから、最低限これが取れることを確認する：
- 業種（複数の可能性あり）
- 店名
- 都道府県
- 住所
- 電話番号

### 1-2. 表記ゆれがないかを別ページで検証する
例：  
https://paypaygourmet.yahoo.co.jp/132304  
同じ項目が同じ表記で載っているか確認する。


---

## Step 2. 「ページ内の各データの取り方」をHTMLから確定する（DevToolsで確認）

ここから先は「実装に迷わない」ために、**項目ごとにセレクタ（取り方）を決めてメモ**します。  
今回の基本情報は、以下のセレクタで取得できる想定です。

### 2-1. 基本情報（店舗詳細ページ）での取得方法
- **業種**：`span[itemprop="servesCuisine"]`
- **名前**：`section div div p:first-child`
- **都道府県**：`span[itemprop="addressRegion"]`
- **住所**：`span[itemprop="streetAddress"]`
- **電話番号**：`p[itemprop="telephone"]`

> itemprop など特殊なのがあるときはそっちを優先させてつかうと特定がしやすい。

> 優先度でいうと、 特殊な属性 > id > classである。
---

## Step 3. 詳細ページへの導線URLパターンを整理する（どこから辿るか）

次に「詳細ページURLをどう集めるか」を決める。  
最も確実なのは、ユーザー目線で実際にサイトを操作して、出てくるURLを観察すること。

### 3-1. ページタイプを分類する（導線ページのURLパターン）
実際に検索・ナビ操作すると、以下のページタイプ（=一覧/検索ページ）が見つかる。

- エリア  
  例：https://paypaygourmet.yahoo.co.jp/area/tokyo/011/0026/  
  パターン：`/area/` から始まる

- ジャンル  
  例：https://paypaygourmet.yahoo.co.jp/t-genre/t-genre3581/  
  パターン：`/t-genre/` から始まる

- シーン  
  例：https://paypaygourmet.yahoo.co.jp/t-scene/t-scene368/  
  パターン：`/t-scene/` から始まる

- 検索結果  
  例：https://paypaygourmet.yahoo.co.jp/search?...  
  パターン：`/search?`（クエリ付き）

> これらは「詳細ページへ飛べるリンクが載っているページ」なので、Scrapyでは基本的に **follow対象（辿る対象）** になる。

---

## Step 4. 詳細ページURLパターンを決める（どれが詳細か判定する）

### 4-1. 詳細ページの共通点をURLから見つける
店舗詳細ページは URL直下に数字IDが入るパターンになっている。

- 例：`https://paypaygourmet.yahoo.co.jp/105355`

### 4-2. 詳細ページ判定ルールを明文化する
- 詳細ページ：`/数字`（ルート直下が数字のみ）
- reviewsページ：`/数字/reviews`

> なお「1から順に全部ある」タイプではなく、試すと404もある。  
> 数字を総当たりする方法も理論上可能だが再現性が低く、今回は **導線ページから辿って集める方針**を採用する。

---

## Step 5. 入口（起点URL）を決める（start_urls）

クロール開始URLは「実際に自分で辿って通った最初のURL」を使うのが安全。

- 基本はトップ（`/`）から始めればよい
- 今回もトップから各ページタイプへ遷移できるため、起点はこれでOK  
  `https://paypaygourmet.yahoo.co.jp/`

---

# まとめ

## A. 詳細ページへの導線URLパターン
- `/area/`
- `/t-genre/`
- `/t-scene/`
- `/search?`

## B. 詳細ページURLパターン
- `/数字`

## C. 詳細ページのデータの取り方（項目ごとの仕様）
- 業種：`span[itemprop="servesCuisine"]`
- 名前：`section div div p:first-child`
- 都道府県：`span[itemprop="addressRegion"]`
- 住所：`span[itemprop="streetAddress"]`
- 電話番号：`p[itemprop="telephone"]`

これを[プロンプト](/prompts/spider)に入力してコードを生成されると以下のような感じのものができる

```python
import os
from datetime import datetime, timezone

import scrapy
from scrapy.linkextractors import LinkExtractor
from scrapy.spiders import CrawlSpider, Rule

# CRAWL_DEBUG が False 相当のときだけ crawlab を使う
def _is_truthy(v: str) -> bool:
    return str(v).strip().lower() in ("1", "true", "yes", "y", "on")

CRAWL_DEBUG = _is_truthy(os.getenv("CRAWL_DEBUG", "false"))
if not CRAWL_DEBUG:
    from crawlab import save_item


class PaypaygurumeSSpider(CrawlSpider):
    name = "paypaygurume_s"
    allowed_domains = ["paypaygourmet.yahoo.co.jp"]
    start_urls = ["https://paypaygourmet.yahoo.co.jp/"]

    rules = (
        # 詳細ページ（絶対URLで判定）
        Rule(
            LinkExtractor(
                allow=(r"^https?://paypaygourmet\.yahoo\.co\.jp/\d+/?$",),
                unique=True,
            ),
            callback="parse_detail",
            follow=False,
        ),
        # 一覧/導線ページ（必要なパスのみ辿る）
        Rule(
            LinkExtractor(
                allow=(
                    r"^https?://paypaygourmet\.yahoo\.co\.jp/area/.*$",
                    r"^https?://paypaygourmet\.yahoo\.co\.jp/t-genre/.*$",
                    r"^https?://paypaygourmet\.yahoo\.co\.jp/t-scene/.*$",
                    r"^https?://paypaygourmet\.yahoo\.co\.jp/search\?.*$",
                ),
                unique=True,
            ),
            follow=True,
        ),
    )

    def parse_detail(self, response):
        # 取得日時はISO8601（ローカルTZ）
        now_iso = datetime.now(timezone.utc).astimezone().isoformat()

        cuisines = [t.strip() for t in response.css('span[itemprop="servesCuisine"]::text').getall() if t.strip()]
        item = {
            "取得日時": now_iso,
            "取得URL": response.url,
            "業種": " / ".join(cuisines) if cuisines else "",
            "名前": (response.css("section div div p:first-child::text").get() or "").strip(),
            "都道府県": (response.css('span[itemprop="addressRegion"]::text').get() or "").strip(),
            "住所": (response.css('span[itemprop="streetAddress"]::text').get() or "").strip(),
            "電話番号": (response.css('p[itemprop="telephone"]::text').get() or "").strip(),
        }

        if not CRAWL_DEBUG:
            save_item(item)

        yield item
```