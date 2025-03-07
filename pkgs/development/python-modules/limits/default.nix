{ lib
, buildPythonPackage
, deprecated
, fetchFromGitHub
, hiro
, packaging
, pymemcache
, pymongo
, pytest-asyncio
, pytest-lazy-fixture
, pytestCheckHook
, pythonOlder
, redis
, setuptools
, typing-extensions
}:

buildPythonPackage rec {
  pname = "limits";
  version = "2.6.1";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "alisaifee";
    repo = pname;
    rev = version;
    # Upstream uses versioneer, which relies on git attributes substitution.
    # This leads to non-reproducible archives on github. Remove the substituted
    # file here, and recreate it later based on our version info.
    extraPostFetch = ''
      rm "$out/limits/_version.py"
    '';
    hash = "sha256-ja+YbRHCcZ5tFnoofdR44jbkkdDroVUdKeDOt6yE0LI=";
  };

  propagatedBuildInputs = [
    deprecated
    packaging
    setuptools
    typing-extensions
  ];

  checkInputs = [
    hiro
    pymemcache
    pymongo
    pytest-asyncio
    pytest-lazy-fixture
    pytestCheckHook
    redis
  ];

  postPatch = ''
    substituteInPlace pytest.ini \
      --replace "--cov=limits" "" \
      --replace "-K" ""
    # redis-py-cluster doesn't support redis > 4
    substituteInPlace tests/conftest.py \
      --replace "import rediscluster" ""

    # Recreate _version.py, deleted at fetch time due to non-reproducibility.
    echo 'def get_versions(): return {"version": "${version}"}' > limits/_version.py
  '';

  pythonImportsCheck = [
    "limits"
  ];

  pytestFlagsArray = [
    # All other tests require a running Docker instance
    "tests/test_limits.py"
    "tests/test_ratelimit_parser.py"
    "tests/test_limit_granularities.py"
  ];

  meta = with lib; {
    description = "Rate limiting utilities";
    homepage = "https://limits.readthedocs.org/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
