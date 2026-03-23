{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  whey,
  sphinx,
  apeye,
  autodocsumm,
  beautifulsoup4,
  cachecontrol,
  dict2css,
  filelock,
  html5lib,
  roman,
  ruamel-yaml,
  sphinx-autodoc-typehints,
  sphinx-jinja2-compat,
  sphinx-prompt,
  sphinx-tabs,
  tabulate,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinx-toolbox";
  version = "4.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sphinx-toolbox";
    repo = "sphinx-toolbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rZRx7qTrNL1RfHUgWXeMjyvoDJyd+NM0iO9pHCBUSII=";
  };

  pythonRelaxDeps = [
    # See https://github.com/sphinx-toolbox/sphinx-toolbox/issues/189
    "sphinx-tabs"
  ];

  build-system = [ whey ];

  dependencies = [
    sphinx
    apeye
    autodocsumm
    beautifulsoup4
    cachecontrol
    dict2css
    filelock
    html5lib
    roman
    ruamel-yaml
    sphinx-autodoc-typehints
    sphinx-jinja2-compat
    sphinx-prompt
    sphinx-tabs
    tabulate
  ];

  # Not PEP420 compliant, some variables are imported from within the package.
  postFixup = ''
    echo '__version__: str = "${finalAttrs.version}"' > $out/${python.sitePackages}/sphinx_toolbox/__init__.py
  '';

  meta = {
    description = "Box of handy tools for Sphinx";
    homepage = "https://github.com/sphinx-toolbox/sphinx-toolbox";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
