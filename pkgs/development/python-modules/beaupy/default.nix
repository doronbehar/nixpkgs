{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  poetry-core,
  emoji,
  python-yakh,
  questo,
  rich,
}:

buildPythonPackage rec {
  pname = "beaupy";
  version = "3.9.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "petereon";
    repo = "beaupy";
    rev = "v${version}";
    hash = "sha256-j+BVEQBC8fbm/zSLTnyGReVSw5xGFGfPiH/MyBpWIMU=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    emoji
    python-yakh
    questo
    rich
  ];

  pythonImportsCheck = [
    "beaupy"
  ];

  # Tests require ward, which is currently broken.
  doCheck = false;

  meta = {
    description = "A Python library of interactive CLI elements you have been looking for";
    homepage = "https://github.com/petereon/beaupy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
