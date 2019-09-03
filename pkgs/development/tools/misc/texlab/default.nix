{ lib
, rustPlatform
, fetchFromGitHub
, nodejs
, citeproc-build-deps
}:

rustPlatform.buildRustPackage rec {
  pname = "texlab";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "latex-lsp";
    repo = pname;
    rev = "v${version}";
    sha256 = "115f63fij0lxcccf7ba9p0lzg1hlfp9i2g7gvvnx0il426h4ynnm";
  };

  cargoSha256 = "0cp8q3qags01s6v3kbghxyzz1hc5rhq6jf15fzz10d1l8mrmw4cy";

  nativeBuildInputs = [ nodejs ];

  patchPhase = ''
    rm build.rs
    ln -s ${citeproc-build-deps}/lib/node_modules/citeproc-build-deps/node_modules src/citeproc/js
  '';

  preBuild = "(cd src/citeproc/js && npm run dist)";

  meta = with lib; {
    description = "An implementation of the Language Server Protocol for LaTeX";
    homepage = https://texlab.netlify.com/;
    license = licenses.mit;
    maintainers = with maintainers; [ doronbehar metadark ];
    platforms = platforms.all;
  };
}
