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

# 手順
## セットアップ
- 自分のいつも作業をしているフォルダに移動する。

- [このレポジトリ](https://github.com/STREAM-inc/stream-scraping-template/archive/refs/heads/main.zip)をダウンロードして配置して解凍する。

- 中にあるファイルをすべて作業フォルダにコピーする。

- (optional) wslにuvをインストール
```sh
wsl
sudo apt update && sudo apt upgrade -y
sudo apt install curl git python3 python3-pip -y
curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

今後基本的にwsl内で作業をする

## プロジェクト開始

```sh
./start.sh <project_name> <host>
cd <project_name>
```

# 動作確認
実際にアプリをデプロイする前にテストをしてください

```sh
make test
```

# デプロイ
テストが完了したら実際にk3s上で動かします。
