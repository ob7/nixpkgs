{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
}:
rustPlatform.buildRustPackage rec {
  pname = "tenere";
  rev = "0f3181a";
  version = "0.11.2-${rev}";
  src = fetchFromGitHub {
    owner = "pythops";
    repo = pname;
    rev = "${rev}";
    hash = "sha256-HKPCX0bmXkB3LwvgE1li3dlWTgpW5CXuWZNq3mFY6FY=";
  };
  cargoHash = "sha256-szYiPunSgnzSXkkYL2xPgieF2ArkTjDjCAfN8OGmZeQ=";

  nativeBuildInputs = [ makeWrapper ];

  CARGO_PROFILE_RELEASE_LTO = "fat";
  CARGO_PROFILE_RELEASE_STRIP = "true";
  CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";
  postInstall = ''
    wrapProgram $out/bin/tenere \
      --run '
        CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/tenere"
        DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/tenere"
        mkdir -p "$CONFIG_DIR"
        mkdir -p "$DATA_DIR"
        chown "$(id -u):$(id -g)" "$CONFIG_DIR" "$DATA_DIR" 2>/dev/null || true
        chmod 755 "$CONFIG_DIR" "$DATA_DIR"
      '
  '';

  requiredSystemFeatures = [ "big-parallel" ]; # fat LTO requires ~3.4GB RAM

  meta = with lib; {
    description = "Terminal interface for large language models (LLMs)";
    homepage = "https://github.com/pythops/tenere";
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl3;
    maintainers = with maintainers; [ ob7 ];
    mainProgram = "tenere";
  };
}
