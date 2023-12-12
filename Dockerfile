# 使用alpine作为基础镜像
FROM golang:1.16-alpine as builder

# 设置工作目录
WORKDIR /app

# 将Go模块复制到容器中
COPY go.mod go.sum ./

# 下载所有依赖项
RUN go mod download

# 将源代码复制到容器中
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 使用alpine作为轻量级基础镜像
FROM alpine:latest

# 添加ca证书
RUN apk --no-cache add ca-certificates

# 设置工作目录
WORKDIR /root/

# 从builder阶段复制二进制文件
COPY --from=builder /app/main .

# 暴露端口
EXPOSE 5000

# 运行二进制文件
CMD ["./main"]