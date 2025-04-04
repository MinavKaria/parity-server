FROM golang:1.23-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git make

COPY . .

RUN make deps 
RUN go build -o parity-server ./cmd/main.go   
RUN chmod +x ./parity-server 

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/parity-server .   
COPY --from=builder /app/config ./config

EXPOSE 8080

RUN echo '#!/bin/sh' > /entrypoint.sh \
    && echo 'PRIVATE_KEY=$(cat /run/secrets/private_key)' >> /entrypoint.sh \
    && echo './parity-server auth --private-key "$PRIVATE_KEY"' >> /entrypoint.sh \
    && echo 'exec "$@"' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

CMD ["./parity-server", "--config", "./config/config.yaml"]
