FROM artifacts.msap.io/mulesoft/core-paas-base-image-node-16:v4.7.26 as BUILD

ENV FIPS_ENABLED=false

WORKDIR /usr/src/app

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY . .

RUN sudo apt update \
    && sudo apt install curl -y \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y \
    && gh

# USER app
# ARG GIT_BRANCH
# ARG GH_TOKEN
# ARG SECRET_KEY
# RUN npx gulp release
