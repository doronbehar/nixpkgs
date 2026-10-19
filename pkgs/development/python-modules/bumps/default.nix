{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  setuptools,

  # dependencies
  aiohttp,
  blinker,
  cloudpickle,
  dill,
  h5py,
  matplotlib,
  msgpack,
  numpy,
  plotly,
  python-socketio,
  scipy,
  versioningit,
}:

buildPythonPackage (finalAttrs: {
  pname = "bumps";
  version = "1.0.5";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-mpfKnzG8TV364kE7VmWa2Rzc0/6mZOmMvczPEHEDqjo=";
  };

  pythonRemoveDeps = [
    "mpld3" # not packaged
  ];

  build-system = [
    setuptools
    versioningit
  ];

  dependencies = [
    aiohttp
    blinker
    cloudpickle
    dill
    h5py
    matplotlib
    msgpack
    numpy
    plotly
    python-socketio
    scipy
    # mpld3 # not packaged
  ];

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [ "bumps" ];

  meta = {
    description = "Data fitting with bayesian uncertainty analysis";
    mainProgram = "bumps";
    homepage = "https://bumps.readthedocs.io/";
    changelog = "https://github.com/bumps/bumps/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ rprospero ];
  };
})
