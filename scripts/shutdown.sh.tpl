#!/bin/bash
gcloud compute routes list --filter=name:${instance_prefix} --format='get(name)' | tr '\n' ' ' |\
  xargs gcloud compute routes delete