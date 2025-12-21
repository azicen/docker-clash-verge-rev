# docker-clash-verge-rev

一个运行 `clash-verge-rev` 的容器镜像，提供桌面环境 + VNC/noVNC 访问，方便在服务器/无界面环境中使用。

你可以：
- **直接拉取镜像运行**（例如 Docker Hub：`adsryen/clash-verge-rev`）
- **在本仓库本地构建**（支持选择上游 Release 版本）

## 快速开始（docker compose）

仓库已提供 `docker-compose.yml`，建议直接使用。

### 1) 启动

```sh
docker compose up -d
```

### 2) 访问 noVNC

默认你本地映射的是：
- **noVNC**：`http://127.0.0.1:16081/vnc.html`
- **VNC**：`127.0.0.1:15901`

如果你修改了 `docker-compose.yml` 里的端口映射，请以你自己的映射为准。

## 构建镜像

本仓库提供两套构建脚本：

- **Windows（PowerShell）**：`build.ps1`
- **Linux/macOS（sh）**：`build.sh`

它们都会从上游 GitHub Releases 拉取版本列表并交互选择，然后使用 `Dockerfile` 构建：

### Windows

```powershell
./build.ps1
```

### Linux/macOS

```sh
sh ./build.sh
```

构建完成后会得到类似：`clash-verge-rev:2.4.4`。

## 端口说明

说明：端口是否真正可用，取决于容器内对应服务是否启动/是否开启（例如 Clash 内核端口需要内核运行后才会监听）。

- **5901/tcp**：VNC
- **6081/tcp**：noVNC Web
- **7897/tcp**：Clash 相关端口（按应用配置，可能需要启动内核后才会监听）
- **9097/tcp**：Clash 相关端口（按应用配置，可能需要启动内核后才会监听）

## 数据持久化与隐私

本仓库默认把数据挂载到 `./config`：

`./config:/config/.local/share/io.github.clash-verge-rev.clash-verge-rev`

为避免把个人订阅/配置提交到仓库，已加入 `.gitignore` 并忽略：
- **`config/`**
- **`.env` / `.env.*`**

如果你之前已经把 `config/` 提交过，需要手动取消跟踪：

```sh
git rm -r --cached config
```

## 常见问题

### 1) 端口绑定失败（Windows：access permissions）

表现：`ports are not available` / `An attempt was made to access a socket in a way forbidden...`

原因：端口被占用或被系统策略拦截。

处理：
- 修改 `docker-compose.yml` 把宿主机端口换成未占用的（例如把 `5901` 改成 `15901`）。

### 2) noVNC 无法粘贴（浏览器报 permission denied）

这是浏览器剪贴板权限限制导致的。

处理：
- 优先用 noVNC 侧边栏的 **Clipboard** 面板发送文本
- 或用独立 VNC 客户端连接 `127.0.0.1:15901`

### 3) GitHub API rate limit

构建脚本默认走公开源（`releases.atom`/网页抓取），避免 REST API 限流。

