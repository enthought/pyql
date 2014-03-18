import re

from quantlib.settings import Settings


def _to_int(s):
    if s is None:
        return None
    else:
        return int(s)


def parse_ql_version_string(version):
    """
    Parse a QuantLib version string.

    Parameters
    ----------
    version : string
        A QuantLib version string of the form major.minor.patch-release,
        where the fields "patch" and "release" are optional.

    Returns
    -------
    A tuple (major, minor, patch, release), where patch and release are
    None if they were not present in the version string.

    """
    m = re.match("^(\d+)\.(\d+)(?:\.(\d+))?(?:-(\w+))?$", version)
    if m is None:
        raise ValueError("Invalid QuantLib version string: {}".format(version))
    major, minor, patch = [_to_int(field) for field in m.groups()[:3]]
    release = m.groups()[3]
    return major, minor, patch, release


QUANTLIB_VERSION = parse_ql_version_string(Settings().version)
