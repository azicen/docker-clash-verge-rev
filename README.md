# docker-clash-verge-rev

一个 `clash-verge-rev` 容器，提供 `WEB VNC` 服务。

## 使用

### 通过 docker run 部署

```sh
docker run \
  --name clash-verge-rev \
  --restart=always \
  -e TZ="Asia/Shanghai" \
  -v "./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev" \
  -p "3000:3000" \
  -p "3001:3001" \
  -p "7897:7897" \
  -p "9097:9097" \
  -d \
  ghcr.io/azicen/clash-verge-rev:latest
```

### 通过 docker-compose 部署

```yaml
services:
  clash-verge-rev:
    container_name: clash-verge-rev
    image: ghcr.io/azicen/clash-verge-rev:latest
    environment:
      TZ: Asia/Shanghai
    volumes:
      - ./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev
    ports:
      - "3000:3000"
      - "3001:3001"
      - "7897:7897"
      - "9097:9097"
    restart: always
```

## 环境变量

| 变量名 | 描述     | 默认值      |
| ------ | -------- | ----------- |
| TZ     | 时区     |             |
| TITLE  | web 标题 | Clash Verge |
