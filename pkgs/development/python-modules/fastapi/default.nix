{ lib
, buildPythonPackage
, fetchFromGitHub
, pydantic
, starlette
, pytestCheckHook
, pytest-asyncio
, aiosqlite
, databases
, fetchpatch
, flask
, httpx
, passlib
, peewee
, python-jose
, sqlalchemy
, trio
, pythonOlder
}:

buildPythonPackage rec {
  pname = "fastapi";
  version = "0.75.2";
  format = "flit";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "tiangolo";
    repo = pname;
    rev = version;
    hash = "sha256-B4q3Q256Sj4jTQt1TDm3fiEaQKdVxddCF9+KsxkkTWo=";
  };

  propagatedBuildInputs = [
    starlette
    pydantic
  ];

  checkInputs = [
    aiosqlite
    databases
    flask
    httpx
    passlib
    peewee
    python-jose
    pytestCheckHook
    pytest-asyncio
    sqlalchemy
    trio
  ] ++ passlib.extras-require.bcrypt;

  patches = [
    # Bump starlette, https://github.com/tiangolo/fastapi/pull/4483
    (fetchpatch {
      name = "support-later-starlette.patch";
      # PR contains multiple commits
      url = "https://patch-diff.githubusercontent.com/raw/tiangolo/fastapi/pull/4483.patch";
      sha256 = "sha256-ZWaqAd/QYEYRL1hSQdXdFPgWgdmOill2GtmEn33vz2U=";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "starlette ==" "starlette >="
  '';

  pytestFlagsArray = [
    # ignoring deprecation warnings to avoid test failure from
    # tests/test_tutorial/test_testing/test_tutorial001.py
    "-W ignore::DeprecationWarning"
  ];

  disabledTestPaths = [
    # Disabled tests require orjson which requires rust nightly
    "tests/test_default_response_class.py"
    # Don't test docs and examples
    "docs_src"
  ];

  disabledTests = [
    "test_get_custom_response"
    # Failed: DID NOT RAISE <class 'starlette.websockets.WebSocketDisconnect'>
    "test_websocket_invalid_data"
    "test_websocket_no_credentials"
    # TypeError: __init__() missing 1...starlette-releated
    "test_head"
    "test_options"
    "test_trace"
  ];

  pythonImportsCheck = [
    "fastapi"
  ];

  meta = with lib; {
    description = "Web framework for building APIs";
    homepage = "https://github.com/tiangolo/fastapi";
    license = licenses.mit;
    maintainers = with maintainers; [ wd15 ];
  };
}
