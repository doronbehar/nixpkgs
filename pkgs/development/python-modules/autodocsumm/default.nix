{
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  setuptools,
  versioneer,
  sphinx,
  lib,
}:
buildPythonPackage rec {
  pname = "autodocsumm";
  version = "0.2.14";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "autodocsumm";
    hash = "sha256-KDmp1PrMPE7M0wbAhpVUCREEK0bur83DID5tC6tAvHc=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/Chilipp/autodocsumm/commit/0609701576308fb447b7ae449576dbce7e672e1a.patch";
      hash = "sha256-Mmxd682cXk6a1LvSWaCY4RmuysMp5IEvlVSSwQJHRbQ=";
    })
  ];

  build-system = [ setuptools ];

  dependencies = [
    versioneer
    sphinx
  ];

  pythonImportsCheck = [ "autodocsumm" ];

  meta = {
    description = "Extended sphinx autodoc including automatic autosummaries";
    homepage = "https://github.com/Chilipp/autodocsumm";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
