# docker-clash-verge-rev

一个使用 `ghcr.io/linuxserver/webtop:ubuntu-xfce` 为基础模型的 `clash-verge-rev` 容器，提供 `WEB VNC` 服务。

## 使用

### 通过 docker run 部署

```sh
docker run \
  --name clash-verge-rev \
  --restart=always \
  -e TZ="Asia/Shanghai" \
  -e LC_ALL="zh_CN.UTF-8" \
  -v "./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev" \
  -p "3000:3000" \
  -p "7897:7897" \
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
      LC_ALL: zh_CN.UTF-8
    volumes:
      - ./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev
    ports:
      - "3000:3000"
      - "7897:7897"
    restart: always
```

## 环境变量

### 必要的环境变量

| 变量名 | 描述     |
| ------ | -------- |
| TZ     | 时区     |
| LC_ALL | 语言环境 |

### 可选的环境变量

查看 [webtop](https://docs.linuxserver.io/images/docker-webtop/#optional-environment-variables) 获得更多可选环境变量。
