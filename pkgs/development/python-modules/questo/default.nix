{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  python-yakh,
  rich,
}:

buildPythonPackage rec {
  pname = "questo";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "petereon";
    repo = "questo";
    rev = "v${version}";
    hash = "sha256-sNzc2CtJJORwApDfJoO53/C/sPqfkohP418jytLGs1A=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    python-yakh
    rich
  ];

  pythonImportsCheck = [
    "questo"
  ];

  # Tests require ward, which is currently broken.
  doCheck = false;

  meta = {
    description = "A library of extensible and modular CLI prompt elements";
    homepage = "https://github.com/petereon/questo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
