FROM golang:alpine AS build

WORKDIR /src

COPY LEAF_Agent LEAF_Agent
COPY pkg pkg

WORKDIR /src/LEAF_Agent
RUN go get leaf-agent && \
    go build -o /app/agent .

FROM scratch
WORKDIR /app
COPY --from=build /app/agent .
CMD ["/app/agent"]
