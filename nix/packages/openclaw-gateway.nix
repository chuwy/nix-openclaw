{
  callPackage,
  lib,
  sourceInfo,
  gatewaySrc ? null,
  pnpmDepsHash ? (sourceInfo.pnpmDepsHash or null),
  bundledAcpx ? null,
  nodejs_26 ? null,
  ...
}:

let
  useNpmPackage =
    gatewaySrc == null && sourceInfo ? gatewayNpmDepsHash && bundledAcpx != null;
in
if useNpmPackage then
  callPackage ./openclaw-gateway-npm.nix (
    { inherit sourceInfo bundledAcpx; } // lib.optionalAttrs (nodejs_26 != null) { inherit nodejs_26; }
  )
else
  callPackage ./openclaw-gateway-source.nix (
    { inherit sourceInfo gatewaySrc pnpmDepsHash; }
    // lib.optionalAttrs (nodejs_26 != null) { inherit nodejs_26; }
  )
