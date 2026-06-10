---
name: deploy-to-ecs
description: 将项目部署到阿里云 ECS 服务器。运维部署、Nginx 配置、网站上线时使用。
---

# 部署到阿里云 ECS

## 服务器信息

| 项目 | 值 |
|------|-----|
| **IP** | 139.224.191.239 |
| **系统** | Alibaba Cloud Linux 3 |
| **账号** | root（密钥 + 密码双认证） |
| **登录** | `ssh root@139.224.191.239`（密钥免密） |

## 已安装服务

| 服务 | 版本 | 状态 | 端口 | 管理方式 |
|------|------|------|------|----------|
| Nginx | 1.24.0 | ✅ 运行中 | 80 | systemctl |
| Docker | 26.1.3 | ✅ 运行中 | - | systemctl |
| Docker Compose | v2.27.0 | ✅ | - | docker compose |
| PostgreSQL | 16 (Alpine) | ✅ 运行中 | 5432 | Docker Compose |
| 宝塔面板 | - | ✅ 运行中 | 8888 | bt 命令 |
| Redis | 无 | - | - | - |

## 宝塔面板

| 项目 | 值 |
|------|-----|
| **地址** | https://139.224.191.239:8888/951a7cf6 |
| **用户名** | user |
| **密码** | 首次登录已过期，需通过 `ssh root@139.224.191.239` 执行 `bt 5` 重置 |

## PostgreSQL

Docker Compose 部署，配置和密码在 `/opt/postgres/docker-compose.yml`。

| 项目 | 值 |
|------|-----|
| **Host** | 139.224.191.239 |
| **Port** | 5432 |
| **User** | admin |
| **Database** | app |

```bash
# 管理命令
docker compose -f /opt/postgres/docker-compose.yml ps     # 查看状态
docker compose -f /opt/postgres/docker-compose.yml restart # 重启
docker exec -it postgres psql -U admin -d app             # 进入数据库
```

## Nginx 配置

```
主配置：/etc/nginx/nginx.conf
站点配置：/etc/nginx/conf.d/*.conf
```

### 当前站点：简历网站

- **目录**：`/var/www/resume/`
- **配置**：`/etc/nginx/conf.d/resume.conf`
- **访问**：http://139.224.191.239

```nginx
server {
    listen 80;
    server_name 139.224.191.239;

    root /var/www/resume;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /assets/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

## 部署新项目

```bash
# 1. 本地构建
pnpm build

# 2. 上传到服务器
ssh root@139.224.191.239 "mkdir -p /var/www/<project>"
scp -r packages/<name>/dist/* root@139.224.191.239:/var/www/<project>/

# 3. 添加 Nginx 配置
ssh root@139.224.191.239 "cat > /etc/nginx/conf.d/<project>.conf << 'EOF'
server {
    listen 80;
    server_name 139.224.191.239;
    root /var/www/<project>;
    index index.html;
    location / {
        try_files \$uri /index.html;
    }
}
EOF
nginx -t && nginx -s reload"
```

## 常用命令

```bash
# Nginx
nginx -t              # 检查配置语法
nginx -s reload       # 热重载配置
systemctl status nginx  # 查看状态
systemctl restart nginx  # 重启

# Docker
docker ps             # 查看运行容器
docker compose up -d  # 启动服务
docker compose down   # 停止服务

# 宝塔
bt status             # 面板状态
bt restart            # 重启面板
```

## 安全组已开放端口

80, 443, 8888, 22, 20, 21
