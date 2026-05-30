{
  description = "Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        buildInputs = with pkgs; [
          flutter
          
          # Linux desktop dependencies
          cmake
          ninja
          pkg-config
          gtk3
          glib
          pcre2
          
          # Optional: Add other tools you might need
          # android-tools
          # jdk17
        ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          xorg.libX11
          xorg.libXext
          xorg.libXrandr
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXi
          libxkbcommon
          dbus
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "flutter-env";
          inherit buildInputs;

          # Fix for linux desktop runner
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

          shellHook = ''
            echo "📱 Flutter development environment loaded"
            echo "Flutter version: $(flutter --version | head -n 1)"
            
            # Uncomment and set these if you are building for Android natively:
            # export JAVA_HOME="${pkgs.jdk17.home}"
            # export ANDROID_HOME="$HOME/Android/Sdk"
            # export ANDROID_SDK_ROOT="$ANDROID_HOME"
          '';
        };
      });
}
