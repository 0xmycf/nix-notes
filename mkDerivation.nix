# 
# https://blog.ielliott.io/nix-docs/mkDerivation.html
# https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-dependencies-overview#
#
{
  # Core Attributes
  name:	string
  pname?:	string
  version?:	string
  src:	path
   
  # Building
  buildInputs?:	list[derivation]
  buildPhase?:	string
  installPhase?:	string
  builder?:	path
   
  # Nix shell
  shellHook?:	string
}
# An example:
stdenv.mkDerivation rec {
  pname = "solo5";
  version = "0.7.5";

  src = fetchurl {
    url = "https://github.com/Solo5/solo5/releases/download/v${version}/solo5-v${version}.tar.gz";
    sha256 = "sha256-viwrS9lnaU8sTGuzK/+L/PlMM/xRRtgVuK5pixVeDEw=";
  };

  nativeBuildInputs = [ makeWrapper pkg-config ];
  buildInputs = [ libseccomp ];

  postInstall = ''
    substituteInPlace $out/bin/solo5-virtio-mkimage \
      --replace "/usr/lib/syslinux" "${syslinux}/share/syslinux" \
      --replace "/usr/share/syslinux" "${syslinux}/share/syslinux" \
      --replace "cp " "cp --no-preserve=mode "

    wrapProgram $out/bin/solo5-virtio-mkimage \
      --prefix PATH : ${lib.makeBinPath [ dosfstools mtools parted syslinux ]}
  '';

  doCheck = true;
  nativeCheckInputs = [ util-linux qemu ];
  checkPhase = '' [elided] '';
}
