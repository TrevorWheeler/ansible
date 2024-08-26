# Dockerfile for testing ansible script

FROM ubuntu:focal AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages including sudo
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y software-properties-common curl git build-essential sudo && \
  apt-add-repository -y ppa:ansible/ansible && \
  apt-get update && \
  apt-get install -y curl git ansible build-essential && \
  apt-get clean autoclean && \
  apt-get autoremove --yes

FROM base AS usersetup
ARG TAGS

# Create the developers group and trev user
RUN addgroup --gid 1000 developers && \
  adduser --gecos trev --uid 1000 --gid 1000 --disabled-password trev && \
  # Add trev to the sudo group
  usermod -aG sudo trev && \
  # Allow passwordless sudo for the trev user
  echo "trev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the trev user
USER trev
WORKDIR /home/trev

FROM usersetup
COPY . .
CMD ["sh", "-c", "ansible-playbook $TAGS local.yml && exec zsh"]
