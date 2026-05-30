{
  description = "Flutter + Android development environment";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url  = "github:numtide/flake-utils";

    # Community flake com Android SDK sempre atualizado
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      # Usa o mesmo nixpkgs para não duplicar downloads
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, android-nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # ── Android SDK via nix-community/android-nixpkgs ────────────
        androidSdk = android-nixpkgs.sdk.${system} (sdkPkgs: with sdkPkgs; [
          cmdline-tools-latest
          # Build-tools — incluindo versões antigas exigidas por plugins Flutter
          build-tools-33-0-2
          build-tools-34-0-0
          build-tools-35-0-0
          build-tools-36-0-0
          platform-tools
          # Platforms — incluindo versões antigas exigidas por plugins Flutter
          platforms-android-33
          platforms-android-34
          platforms-android-35
          platforms-android-36
          emulator
          # CMake do Android SDK — exigido pelo NDK para arm64
          cmake-3-22-1
          # NDK exigido pelo Flutter 3.41.x
          ndk-28-2-13676358
          # System image para o emulador
          system-images-android-36-google-apis-x86-64
        ]);

        # ── JDK 17 (requerido pelo AGP moderno) ─────────────────────
        jdk = pkgs.jdk17;

        # ── Dependências Linux desktop ───────────────────────────────
        linuxDeps = with pkgs; [
          cmake ninja pkg-config
          gtk3 glib pcre2 sysprof
          libx11 libxext libxrandr
          libxcursor libxinerama libxi
          libxkbcommon dbus
        ];

        buildInputs = with pkgs; [
          flutter
          jdk
          androidSdk
          android-tools   # adb, fastboot
        ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxDeps;

      in
      {
        devShells.default = pkgs.mkShell {
          name = "flutter-android-env";
          inherit buildInputs;

          JAVA_HOME        = "${jdk.home}";
          ANDROID_HOME     = "${androidSdk}/share/android-sdk";
          ANDROID_SDK_ROOT = "${androidSdk}/share/android-sdk";
          ANDROID_NDK_HOME = "${androidSdk}/share/android-sdk/ndk/28.2.13676358";

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          shellHook = ''
            echo "📱 Flutter + Android dev environment"
            echo "Flutter : $(flutter --version 2>/dev/null | head -n 1)"
            echo "Java    : $(java -version 2>&1 | head -n 1)"
            echo "ADB     : $(adb version 2>/dev/null | head -n 1)"
            echo ""
            echo "ANDROID_HOME → $ANDROID_HOME"
            echo ""

            # ── Gera android/local.properties com caminhos do Nix ──────
            # Impede o Gradle de tentar baixar SDK components em runtime
            cat > "android/local.properties" <<EOF
sdk.dir=$ANDROID_HOME
ndk.dir=$ANDROID_HOME/ndk/28.2.13676358
cmake.dir=$ANDROID_HOME/cmake/3.22.1
EOF
            echo "✅ android/local.properties gerado."
            echo ""

            # ── Cria o AVD automaticamente na primeira vez ──────────
            AVD_NAME="flutter_avd"
            AVD_PKG="system-images;android-36;google_apis;x86_64"

            if ! avdmanager list avd 2>/dev/null | grep -q "Name: $AVD_NAME"; then
              echo "🔧 Criando emulador '$AVD_NAME' (primeira execução)..."
              echo "no" | avdmanager create avd \
                --name    "$AVD_NAME" \
                --package "$AVD_PKG" \
                --force   2>/dev/null && \
                echo "✅ AVD '$AVD_NAME' criado com sucesso!" || \
                echo "⚠️  Falha ao criar AVD — verifique se a system image foi baixada."
            else
              echo "✅ AVD '$AVD_NAME' já existe."
            fi

            # ── Verifica KVM (necessário para emulador rápido) ──────
            if [ -e /dev/kvm ]; then
              echo "✅ KVM disponível — emulador rodará em hardware acceleration."
            else
              echo "⚠️  KVM não detectado. O emulador pode ser lento."
              echo "   Ative a virtualização na BIOS ou use um dispositivo físico."
            fi

            echo ""
            echo "Para iniciar o emulador: flutter emulators --launch $AVD_NAME"
            echo "Para rodar o app:        flutter run"
          '';
        };
      });
}
