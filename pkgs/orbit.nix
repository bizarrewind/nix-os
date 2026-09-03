{ lib, rustPlatform, fetchFromGitHub, pkg-config, wrapGAppsHook4, gtk4, gtk4-layer-shell, glib, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "orbit";
  version = "2.4.13";

  src = fetchFromGitHub {
    owner = "LifeOfATitan";
    repo = "orbit";
    rev = "eb772615558b61cda81861a3fbac49f7e37dc1f8";
    hash = "sha256-18xO4DcU9u3FFem19muJ0R8K7V/mzOp68EE5ASQ3swg=";
  };

  cargoHash = "sha256-ipjbGpfkpAxSq2vjx70BRcIjRdF2GfpEAUMsHmD7R+A=";

  patches = [
    ./orbit-remove-logo.patch
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
    glib
    openssl
  ];

  meta = with lib; {
    description = "A native network & Bluetooth manager for Wayland using Rust, GTK4, and layer-shell";
    homepage = "https://github.com/LifeOfATitan/orbit";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "orbit";
  };
}
