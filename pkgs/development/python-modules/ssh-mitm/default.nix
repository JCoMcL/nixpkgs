{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, colored
, enhancements
, packaging
, paramiko
, pytz
, pyyaml
, requests
, rich
, sshpubkeys
, typeguard
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "ssh-mitm";
  version = "2.0.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    hash = "sha256-1Vx68ISsT2Vrzy3YBqDqcGEHXHzdKR8jTtBH9SNXT2s=";
  };

  propagatedBuildInputs = [
    colored
    enhancements
    packaging
    paramiko
    pytz
    pyyaml
    requests
    rich
    sshpubkeys
    typeguard
  ];

  # Module has no tests
  doCheck = false;

  pythonImportsCheck = [
    "sshmitm"
  ];

  meta = with lib; {
    description = "Tool for SSH security audits";
    homepage = "https://github.com/ssh-mitm/ssh-mitm";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ fab ];
  };
}
