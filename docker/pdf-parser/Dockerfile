# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /build

# Install git for go get
RUN apk add --no-cache git

# Copy go mod file
COPY pdf-parser/go.mod ./

# Copy source code
COPY pdf-parser/main.go ./

# Download dependencies and generate go.sum
RUN go mod download && go mod tidy

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o pdf-parser .

# Runtime stage
FROM alpine:latest

# Install ca-certificates for HTTPS and poppler-utils for pdftotext
RUN apk --no-cache add ca-certificates poppler-utils

WORKDIR /app

# Create non-root user
ARG BUILD_UID=1000
RUN adduser -D -u ${BUILD_UID} build_user

# Copy binary from builder
COPY --from=builder /build/pdf-parser .

# Change ownership
RUN chown -R build_user:build_user /app

USER build_user

EXPOSE 9000

CMD ["./pdf-parser"]