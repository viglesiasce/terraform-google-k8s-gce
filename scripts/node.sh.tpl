#!/bin/bash

kubeadm join --token=${token} ${master_ip}:6443