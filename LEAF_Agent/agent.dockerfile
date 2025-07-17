FROM quay.vapo.va.gov/2195_leaf/golang:1-alpine AS build

USER root

WORKDIR /src

COPY LEAF_Agent LEAF_Agent
COPY pkg pkg

WORKDIR /src/LEAF_Agent
RUN go build -o /app/agent .

FROM scratch
WORKDIR /app
COPY --from=build /app/agent .

RUN mkdir /.cache && \
    chown -R 1001:1001 /app /src /go /.cache
