# docker-clash-verge-rev

一个 `clash-verge-rev` 容器，提供 `WEB VNC` 服务。

## 使用

### 通过 docker run 部署

```sh
docker run \
  --name clash-verge-rev \
  --restart=always \
  -e TZ="Asia/Shanghai" \
  -e VNC_PORT=5901 \
  -e NOVNC_PORT=6081 \
  -v "./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev" \
  -p "5901:5901" \
  -p "6081:6081" \
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
      VNC_PORT: 5901
      NOVNC_PORT: 6081
    volumes:
      - ./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev
    ports:
      - "5901:5901"
      - "6081:6081"
      - "7897:7897"
      - "9097:9097"
    restart: always
```

## 环境变量

| 变量名       | 描述               | 默认值      |
| ------------ | ------------------ | ----------- |
| TZ           | 时区               |             |
| VNC_HOST     | VNC 监听地址       | 127.0.0.1   |
| VNC_PORT     | VNC 监听端口       | 5901        |
| VNC_GEOMETRY | VNC 显示分辨率     | 1280x800    |
| TITLE        | noVNC web 标题     | Clash Verge |
| NOVNC_HOST   | noVNC web 监听地址 | 0.0.0.0     |
| NOVNC_PORT   | noVNC web 监听端口 | 6081        |
