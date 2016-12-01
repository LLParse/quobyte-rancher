#!/bin/bash

META_URL="http://rancher-metadata.rancher.internal/2015-12-19"
get_label() { curl -s "${META_URL}/self/host/labels/${1}"; }
