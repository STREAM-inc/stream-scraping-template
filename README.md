# STRAEM スクレイピングマニュアル
## 目的
スクレイピング業務の工数削減、透明化を図る。

## 方法

### スクレイピングプロジェクトの形式統一

[scrapy](https://docs.scrapy.org/en/latest/intro/overview.html)というcrawler開発のためのライブラリを使用する。送信速度、同時処理数、リンクの処理、データの保存方法などを決まったプロジェクトファイルの設定をすることで簡単に設定できる。

scrapyを使うことで
- スクレイピング状況の保存 -> 障害耐性  
- リトライ設定 -> 障害耐性
- 書き方の統一 -> シームレスな引継ぎ

を達成することができる。


--- 

### コンテナ化

[Docker](https://docs.docker.com/get-started/docker-overview/)を使いプロジェクトをコンテナ化する。

Dockerをつかうことで、
- パッケージの依存管理 -> どのコンピュータでもすぐ動かせる
- リソース制御 -> 使用するCPU, memory, network bandwidthを制御できる

----

### 分散処理
K3S (ローカルクラスタ構築に必要最低限の機能を備えた[kubernetes](https://kubernetes.io/ja/docs/home/))を使い社内コンピューターを複数活用する。

k3sを使うことで、
- 分散処理 -> 様々な制限かでの高速化
- リソース管理 -> それぞれのコンピュータの空きリソースを適切に活用
- デプロイ -> コマンド一つで複数コンピュータに同時にデプロイ

--- 

### 監視
[prometheus](https://prometheus.io/)を使いスクレイピング状況を監視する(開発者用)

prometheusを使うことで
- 柔軟な監視 -> 速度、異常事態を通知
- grafanaへのエクスポート -> 状況の可視化

#### metrics
- scraper_site_visited_count
- scraper_site_visited_total
- scraper_site_visited_rate
- scraper_site_visited_error_count
- scraper_site_visited_error_total
- scraper_site_visited_error_rate
- scraper_site_extracted_count
- scraper_site_extracted_total
- scraper_site_extracted_rate

# 手順
## セットアップ

### wslにuvをインストール
```sh
sudo apt update && sudo apt upgrade -y
sudo apt install curl git python3 python3-pip -y
curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

### wslにdockerをインストール
```
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### テンプレートをインストール
```sh
git clone git@github.com:STREAM-inc/stream-scraping-template.git
cd stream-scraping-template
uv sync
echo "export PATH=\"\$PATH:$(pwd)\"" >> ~/.bashrc
echo "export STREAM_TEMPLATE_PATH=\"$(pwd)\"" >> ~/.bashrc
source ~/.bashrc
```

### アップデート
```sh
wsl
cd <path-to-stream-scraping-template>
git checkout main
git pull origin main
```

今後基本的にwsl内で作業をする。wslないなら基本どこでもいいがホームディレクトリ直下などでやると良いと思う。stream-scraping-template内では作業しないでください。

## プロジェクト開始
プロジェクト名はすべて小文字にしてください。
```sh
start-scraping.sh <project_name> <host>
cd <project_name>
```

# 動作確認
実際にアプリをデプロイする前にテストをしてください

```sh
make test
```

# デプロイ
テストが完了したら実際にk3s上で動かします。

