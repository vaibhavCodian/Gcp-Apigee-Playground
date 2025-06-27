FROM golang:1.22-alpine
WORKDIR /app
COPY . .
RUN go build -o go-service main.go
CMD ["./go-service"]
