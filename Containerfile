FROM docker.io/debian:13 AS build

ARG PYTHON_3_11_VERSION=3.11.15
ARG PYTHON_3_12_VERSION=3.12.13
ARG PYTHON_3_13_VERSION=3.13.14
ARG PYTHON_3_14_VERSION=3.14.6

ENV UV_PYTHON_INSTALL_DIR=/usr/share/uv/python \
    UV_TOOL_DIR=/usr/share/uv/tools \
    UV_TOOL_BIN_DIR=/usr/local/bin \
    UV_PYTHON_BIN_DIR=/usr/local/bin

COPY --from=ghcr.io/astral-sh/uv:0.11.21 /uv /usr/local/bin/uv

RUN uv python install "${PYTHON_3_11_VERSION}" "${PYTHON_3_12_VERSION}" "${PYTHON_3_13_VERSION}" "${PYTHON_3_14_VERSION}"

RUN ln -sf /usr/local/bin/python3.13 /usr/local/bin/python3 && \
    ln -sf /usr/local/bin/python3.13 /usr/local/bin/python

RUN uv tool install --python=3.13 aws-sam-cli && \
    uv tool install --python=3.13 poetry && \
    uv tool install --python=3.13 checkov && \
    uv tool install --python=3.13 pre-commit && \
    uv tool install --python=3.13 podman-compose

RUN mkdir -p /dist/usr/local /dist/usr/share && \
    mv /usr/local/bin /dist/usr/local && \
    mv /usr/share/uv /dist/usr/share

FROM scratch
COPY --from=build /dist /
