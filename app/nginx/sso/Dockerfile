FROM golang:1.19 AS build-stage
WORKDIR /app
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /go-bin main.go

# FROM gcr.io/distroless/base-debian11 AS build-release-stage
FROM alpine AS build-release-stage
WORKDIR /
COPY --from=build-stage /go-bin /go-bin
ENTRYPOINT ["/go-bin"]