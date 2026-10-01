#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

snap install kubectl --classic
