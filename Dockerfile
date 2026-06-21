FROM golang:1.26.3-alpine AS builder

WORKDIR /app

RUN apk add --no-cache upx ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .

ENV GO111MODULE=on
RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build \
    -a -ldflags '-s -w' -installsuffix cgo \
    -o backend ./cmd/api

RUN upx -9 backend

FROM alpine:3.22

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/backend /app/backend
COPY --from=builder /app/swagger /app/swagger

CMD ["/app/backend"]
