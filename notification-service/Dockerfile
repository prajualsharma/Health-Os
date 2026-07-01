# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS build
WORKDIR /src
RUN apk add --no-cache git ca-certificates

COPY pkg/healthos ./pkg/healthos
COPY notification-service ./notification-service

WORKDIR /src/notification-service
ENV GOWORK=off
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -ldflags="-s -w" -o /notification-service ./cmd/server

FROM alpine:3.20
RUN apk add --no-cache ca-certificates wget
WORKDIR /app
COPY --from=build /notification-service /app/notification-service
EXPOSE 8082
ENTRYPOINT ["/app/notification-service"]
