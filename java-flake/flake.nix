{
  description = "Java development flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          basePackages = with pkgs; [ 
            temurin-bin-18
            gradle_7
          ];
          title = "jt"; # this is used in mkDerivation
          version = "0.0.1";
      in {

        defaultPackage = pkgs.stdenv.mkDerivation {

          # # Core Attributes
          name = title;
          version = version;
          src = ./.; # only files tracked in git (if it is a git repository) are included (I think)

          # # Building
          buildInputs = with pkgs; [
            # gnumake
            ] ++ basePackages;
          buildPhase = ''
            gradle build
            '';
          # assumes the app is in app/ (app/src/)
          installPhase = 
            let v = if version == "" 
                  then ""
                  else "-" + version;
            in
              ''
              mkdir -p $out/bin  
              cp app/build/libs/app${v}.jar $out/bin || cp app/build/libs/${name}${v}.jar $out/bin \
                || cp build/libs/app${v}.jar $out/bin || cp build/libs/${name}${v}.jar $out/bin
              '';

        } ;

        devShell = pkgs.mkShell {
          name = "basic java nix shell";
          packages = with pkgs; [
            # add packages here you need in the shell but not the build
          ] ++ basePackages;
          shellHook = "which javac";
        };
      });
    }

