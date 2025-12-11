# k3s cluster 構築手順

### docker
```sh
sudo mkdir /etc/docker
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "insecure-registries": ["192.168.100.3:5000"]
}
EOF
```

## agent
```sh
export K3STOKEN=$(redis-cli -h 192.168.100.3 GET K3STOKEN)
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.30.4+k3s1" K3S_URL=https://192.168.100.3:6443 K3S_TOKEN=$K3STOKEN sh -
```


```sh
sudo mkdir /etc/rancher/k3s
sudo tee /etc/rancher/k3s/registries.yaml << 'EOF'
mirrors:
  "192.168.100.3:5000":
    endpoint:
      - "http://192.168.100.3:5000"
EOF
```
