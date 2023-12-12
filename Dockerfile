# 使用匹配的Go版本作为基础镜像
FROM golang:1.21-alpine as builder

# 设置工作目录
WORKDIR /app

# 将从 ahui2016/temp-files 仓库中检出的源代码复制到容器中
COPY app/ .
# 将Go模块和源代码复制到容器中
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 使用alpine作为轻量级基础镜像
FROM alpine:latest

# 添加非 root 用户
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

WORKDIR /home/appuser

# 从builder阶段复制二进制文件
COPY --from=builder /app/main .

# 暴露端口
EXPOSE 5000

# 运行二进制文件
CMD ["./main"]