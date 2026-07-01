# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS build
WORKDIR /src
RUN apk add --no-cache git ca-certificates

COPY pkg/healthos ./pkg/healthos
COPY kitchen-service ./kitchen-service

WORKDIR /src/kitchen-service
ENV GOWORK=off
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -ldflags="-s -w" -o /kitchen-service ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates wget
WORKDIR /app
COPY --from=build /kitchen-service /app/kitchen-service
COPY kitchen-service/migrations /app/migrations
ENV MIGRATIONS_PATH=file:///app/migrations
EXPOSE 8083
ENTRYPOINT ["/app/kitchen-service"]
