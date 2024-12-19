{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "python-yakh";
  version = "0.3.2";
  pyproject = true;

  src = fetchPypi {
    # NOTE that this is not https://pypi.org/project/yakh/
    pname = "python_yakh";
    inherit version;
    hash = "sha256-8oM6TADZgjseO1F7cb/LZy+B1Olxn0MmOJzvOPWxv+M=";
  };

  build-system = [
    poetry-core
  ];

  pythonImportsCheck = [
    "yakh"
  ];

  # Tests require ward, which is currently broken.
  doCheck = false;

  meta = {
    description = "Yet Another Keypress Handler";
    homepage = "https://pypi.org/project/python-yakh";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
