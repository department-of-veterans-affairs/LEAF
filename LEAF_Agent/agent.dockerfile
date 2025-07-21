FROM quay.vapo.va.gov/2195_leaf/golang:1-alpine AS build

USER root

WORKDIR /app
COPY LEAF_Agent/agent .

RUN mkdir /.cache && \
    chmod -R 775 /app /go /.cache
