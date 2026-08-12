# OpenClaw requires a WAL-reset-safe SQLite (>=3.51.3, or backports
# 3.50.7+/3.44.6+); see upstream's sqlite-runtime-version check.
#
# nixpkgs builds Node.js >=22.5 with --shared-sqlite, so the SQLite that
# node:sqlite / process.versions.sqlite reports is the nixpkgs `sqlite`
# version, not Node's bundled one. A nixpkgs pin with an affected SQLite
# (e.g. 3.51.2) makes every Node version unsafe.
#
# When the incoming nixpkgs SQLite is safe, return the cached nodejs_26
# binary unchanged. When it is affected, rebuild nodejs_26 against a pinned
# safe SQLite so the packaged gateway always passes the upstream WAL check.
{ pkgs }:
let
  lib = pkgs.lib;
  isWalSafeSqlite =
    version:
    lib.versionAtLeast version "3.51.3"
    || (lib.versions.majorMinor version == "3.50" && lib.versionAtLeast version "3.50.7")
    || (lib.versions.majorMinor version == "3.44" && lib.versionAtLeast version "3.44.6");
in
if isWalSafeSqlite pkgs.sqlite.version then
  pkgs.nodejs_26
else
  pkgs.nodejs_26.override {
    sqlite = pkgs.sqlite.overrideAttrs (_old: {
      version = "3.53.3";
      src = pkgs.fetchurl {
        url = "https://sqlite.org/2026/sqlite-src-3530300.zip";
        hash = "sha256-u4C/ijv/wZJBzoq6WkvHTpw5gAE8sLXw8JdqmVFpQq8=";
      };
    });
  }
