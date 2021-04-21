def _get_platform_specific_config(os_name):
    _WINDOWS = {
        "sha256": "ec37f535265ce93953a874b10d07e8578f9814c206d8bce6a241ba7016297e4f",
        "prefix": "xpack-openocd-0.11.0-1",
        "url": "https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.11.0-1/xpack-openocd-0.11.0-1-win32-x64.zip",
    }
    _PLATFORM_SPECIFIC_CONFIGS = {
        "mac os x": {
            "sha256": "3e3719fd059d87f3433f1f6d8e37b8582e87ae6a168287eb32a85dbc0f2e1708",
            "prefix": "xpack-openocd-0.11.0-1",
            "url": "https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.11.0-1/xpack-openocd-0.11.0-1-darwin-x64.tar.gz",
        },
        "linux": {
            "sha256": "5972fe70a274f054503dd519b68d3909b83f017b5b8dd2b59e84b3b72c9bc3e1",
            "prefix": "xpack-openocd-0.11.0-1",
            "url": "https://github.com/xpack-dev-tools/openocd-xpack/releases/download/v0.11.0-1/xpack-openocd-0.11.0-1-linux-x64.tar.gz",
        },
        "windows": _WINDOWS,
        "windows server 2019": _WINDOWS,
        "windows 10": _WINDOWS,
    }
    if os_name not in _PLATFORM_SPECIFIC_CONFIGS.keys():
        fail("OS configuration not available for:", os_name)
    return _PLATFORM_SPECIFIC_CONFIGS[os_name]

def _openocd_repository_impl(repository_ctx):
    tar_name = "openocd.tgz"

    config = _get_platform_specific_config(repository_ctx.os.name)
    prefix = config["prefix"]
    repository_ctx.download_and_extract(
        url = config["url"],
        sha256 = config["sha256"],
        stripPrefix = prefix,
    )

    # Bazel does not support unicode character targets in download and extract, so extraction happens as a seperate step and files containing unicode characters are removed
    setup_script_template = """
    set -eux pipefail
    tar -zxvf {tar_name}
    # Remove files with unicode characters as bazel doesn't like them
    /bin/mv {prefix}/* ./
    /bin/rm -r  {tar_name}
    """
    executable_extension = ""
    if "windows" in repository_ctx.os.name:
        executable_extension = ".exe"
    repository_ctx.symlink("bin/openocd"+ executable_extension, "openocd" )
    
    repository_ctx.file(
        "BUILD",
        content = """
package(default_visibility = ["//visibility:public"])
exports_files(["openocd"])
""",
    )

openocd_repository = repository_rule(
    _openocd_repository_impl,
)

def openocd_deps():
    """ openocd_deps fetchs openocd from the xpack repositories
    """
    openocd_repository(name = "com_openocd")
