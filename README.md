# STRAEM スクレイピングマニュアル
## 目的
スクレイピング業務の工数削減、透明化を図る。

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

## Crawlabの設定
crawlabで複数のコンピューターを使う場合、masterとworkerという役割分担があります。masterは一番信頼できる、スペックの高い環境で実行するのが望ましいです。

### crawlab masterノードの設定
powershellを実行権限で開いて実行。
```sh
# windows のfirewallをcrawlabが使うportで無効化する
New-NetFirewallRule `
  -DisplayName "WSL Port 9666" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 9666 `
  -Action Allow

# 8080
New-NetFirewallRule `
  -DisplayName "WSL Port 8080" `
  -Direction Inbound `
  -Protocol TCP `
  -LocalPort 8080 `
  -Action Allow

# windows -> wsl のproxy設定
netsh interface portproxy add v4tov4 `
  listenaddress=0.0.0.0 `
  listenport=9666 `
  connectaddress=$WSL_IP `
  connectport=9666

netsh interface portproxy add v4tov4 `
  listenaddress=0.0.0.0 `
  listenport=8080 `
  connectaddress=$WSL_IP `
  connectport=8080

```

wslを起動して中で実行する
```sh
cd
mkdir crawlab && cd crawlab
sudo tee docker-compose.yml << 'EOF'
# master node
version: '3.3'
services:
  master:
    image: crawlabteam/crawlab
    container_name: crawlab_master
    restart: always
    environment:
      CRAWLAB_NODE_MASTER: "Y"  # Y: master node
      CRAWLAB_MONGO_HOST: "mongo"  # mongo host address. In the docker compose network, directly refer to the service name
      CRAWLAB_MONGO_PORT: "27017"  # mongo port 
      CRAWLAB_MONGO_DB: "crawlab"  # mongo database 
      CRAWLAB_MONGO_USERNAME: "username"  # mongo username
      CRAWLAB_MONGO_PASSWORD: "password"  # mongo password 
      CRAWLAB_MONGO_AUTHSOURCE: "admin"  # mongo auth source 
    volumes:
      - "/opt/.crawlab/master:/root/.crawlab"  # persistent crawlab metadata
      - "/opt/crawlab/master:/data"  # persistent crawlab data
      - "/var/crawlab/log:/var/log/crawlab" # log persistent 
    ports:
      - "8080:8080"  # exposed api port
      - "9666:9666"  # exposed grpc port
    depends_on:
      - mongo

  mongo:
    image: mongo:4.2
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: "username"  # mongo username
      MONGO_INITDB_ROOT_PASSWORD: "password"  # mongo password
    volumes:
      - "/opt/crawlab/mongo/data/db:/data/db"  # persistent mongo data
    ports:
      - "27017:27017"  # expose mongo port to host machine
EOF
```

### crawlab workerノードの設定

masterノードのPCに移ってIPを確認する
```sh
ipconfig
```

192.168.100.xみたいな形になっているはずです。
この値は以下のコードの<master_node_ip>と置き換えて設定してください。

wslを起動し中で実行
```sh
cd
mkdir crawlab && cd crawlab
sudo tee docker-compose.yml << 'EOF'
# worker node
version: '3.3'
services:
  worker:
    image: crawlabteam/crawlab
    container_name: crawlab_worker
    restart: always
    environment:
      CRAWLAB_NODE_MASTER: "N"  # N: worker node
      CRAWLAB_GRPC_ADDRESS: "<master_node_ip>:9666"  # grpc address
      CRAWLAB_FS_FILER_URL: "http://<master_node_ip>:8080/api/filer"  # seaweedfs api
    volumes:
      - "/opt/.crawlab/worker:/root/.crawlab"  # persistent crawlab metadata
      - "/opt/crawlab/worker:/data"  # persistent crawlab data
EOF
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


