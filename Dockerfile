FROM golang:1.23-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git make

COPY . .

RUN make deps
RUN make build

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/parity-server .   

COPY --from=builder /app/config ./config

EXPOSE 8080

CMD ["./parity-server", "server", "--config", "./config/config.yaml"]
