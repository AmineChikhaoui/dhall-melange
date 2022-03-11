#! /usr/bin/env bash

workDir=$(mktemp -d "melange-build-XXX")

cleanup() {
  rm -rf "$workDir"
}

trap cleanup EXIT

dhall-to-yaml --file ./tailscale.dhall > tailscale.yaml

cp -v ./conf/* "$workDir"

melange build tailscale.yaml --workspace-dir="$workDir"
