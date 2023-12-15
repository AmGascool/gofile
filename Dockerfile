### Step one
# 使用匹配的Go版本作为基础镜像
FROM golang:1.21-alpine as builder

# 设置工作目录
WORKDIR /app

# 从 ahui2016/temp-files 仓库中检出的源代码复制到容器中
COPY app/ .

# 下载所有依赖项
RUN go mod download

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

### Step Two
# 使用alpine作为轻量级基础镜像
FROM alpine:latest

WORKDIR /root

# 从builder阶段复制二进制文件
COPY --from=builder /app/main /app/app_config_default.toml .

# 暴露端口
EXPOSE 5000

# 运行二进制文件
CMD ["./main"]