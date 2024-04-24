# Based on this: https://github.com/MathiasPius/kronform/blob/main/tools/Dockerfile
# MIT License

# Copyright (c) 2024 Mathias Pius

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This stage is responsible for downloading all the binaries which make up
# our toolset. We'll later copy the tools to a separate stage designed for running.
FROM debian:bookworm-slim AS installer

# Using arguments allows us to update the tools easily in the future.
# Docker is supposed to allow multi-stage variables but it's very unreliable.
# Python and makejinja version are listed below.
ARG KUBECTL_VERSION="1.29.2"
ARG YQ_VERSION="4.40.5"
ARG SOPS_VERSION="3.8.1"
ARG FLUX_VERSION="2.2.3"
ARG JUST_VERSION="1.25.2"

# Install curl and CA certificates, so we can access GitHub over HTTPS.
RUN apt-get update \
    && apt-get -y install --no-install-recommends ca-certificates curl \
    && apt-get clean

# Create a /tools directory so we can copy all of them over wholesale.
RUN mkdir -p /tools
WORKDIR /tools

RUN curl -L -o kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod u+x kubectl

RUN curl -L -o yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 \
    && chmod u+x yq

RUN curl -L -o sops https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 \
    && chmod u+x sops

RUN curl -L -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz \
    && tar -xf flux.tar.gz \
    && rm flux.tar.gz \
    && chmod u+x flux

RUN curl -L -o just.tar.gz https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz \
    && tar -xf just.tar.gz \
    && rm just.tar.gz \
    && chmod u+x just

# ===========================================================================
# Stage which contains only the tools required, set up to run as the default
# non-root linux user, so that mounting our working directory into it won't
# cause all kinds of ownership issues.
FROM debian:bookworm-slim AS workspace

# Python and pip dependencies versions, as well as virtual environment directory.
ARG PYTHON_VERSION="3.11"
ARG MAKEJINJA_VERSION="2.5.0"
ARG VIRTUAL_ENV="/opt/venv"
ENV EDITOR="nano"

# Install python, pip and virtual environment.
RUN apt-get update \
    && apt-get -y install --no-install-recommends python${PYTHON_VERSION} python3-pip python${PYTHON_VERSION}-venv ${EDITOR} \
    && apt-get clean

# Setup virtual environment.
RUN python3 -m venv $VIRTUAL_ENV

# Add to path.
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install makejinja.
RUN pip install makejinja==${MAKEJINJA_VERSION}

# Create group and user.
ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} user
RUN useradd -m -s /bin/bash -u ${UID} -g ${GID} user

# We'll mount the repository in /data
RUN mkdir /data && chown user:user /data
WORKDIR /data

# Copy all the tools from our installer stage.
COPY --chown=user:user --from=installer /tools/* /usr/local/bin/

# Copy in our entrypoint which is used for setting up the environment.
COPY --chown=user:user --chmod=0700 entrypoint.sh /usr/bin/local/entrypoint

USER ${UID}
ENTRYPOINT ["/usr/bin/local/entrypoint"]