load(":stm32f1_defs.bzl", "STM32_DEFINES")

VERSIONS = {
    "1.8.2" : {
        "commit" : "441b2cbdc25aa50437a59c4bffe22b88e78942c9",
        "sha256" : ""
    }
}


def _stm32f1xx_repository_impl(rctx):
    REPOSITORY_NAME = "STM32CubeF1"
    BASE_URL = "https://github.com/STMicroelectronics/" + REPOSITORY_NAME + "/archive/"

    version_info = VERSIONS[rctx.attr.version]
    rctx.download_and_extract(
        url = BASE_URL + version_info["commit"] + ".zip",
        stripPrefix = REPOSITORY_NAME + "-" + version_info["commit"],
        sha256 = version_info["sha256"],
    )
    rctx.symlink(Label("//third_party_libs/devices/arm/st_microelectronics/stm32f1cube:stm32f1_defs.bzl"), "stm32f1_defs.bzl")
    target_template = """
stm32f1_project(
    name = "{name}",
    config = "{config}",
)
"""

    startup_template = """
cc_library(
    name = "startup_{device}",
    srcs = ["Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_{device}.s"],
    alwayslink = True,
    tags = ["manual"],
)
"""
    tartup_targets = [startup_template.format(device = device) for device in STM32_DEFINES.keys()]
    startup_targets_str = "\n".join(startup_targets)
    targets = [target_template.format(config = config, name = name) for name, config in rctx.attr.project_configs.items()]
    targets_str = "\n".join(targets)
    rctx.file("BUILD", """
package(default_visibility = ["//visibility:public"])
exports_files(glob(["**/*.s"]))
load(":stm32f1_defs.bzl","stm32f1_project")
""" + targets_str + startup_targets_str)

stm32f1_repository_simple = repository_rule(
    implementation = _stm32f1xx_repository_impl,
    attrs = {
        "version": attr.string(
            doc = "Release version of repository",
            default = "v1.7.0",
            values = VERSIONS.keys(),
        ),
        "project_configs": attr.string_dict(
            doc = "The key as the named prefix for this project and the value as the Label for your projects config cc_library",
            mandatory = True,
        ),
    },
)

def stm32f1_repository(project_configs, version = "v1.7.0"):
    stm32f1_repository_simple(name = "stm32f1cube", project_configs = project_configs, version = version)



