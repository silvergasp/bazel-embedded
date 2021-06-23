load("@rules_cc//cc:defs.bzl", "cc_library")


INCLUDE_DIRECTORIES = [
    "Drivers/CMSIS/Core_A/Include",
    "Drivers/CMSIS/Core/Include",
    "Drivers/CMSIS/Device/ST/STM32F1xx/Include",
    "Drivers/CMSIS/DSP/Include",
    "Drivers/CMSIS/Include",
    "Drivers/CMSIS/NN/Include",
    "Drivers/CMSIS/RTOS2/Include",
    "Drivers/STM32F1xx_HAL_Driver/Inc",
    "Drivers/STM32F1xx_HAL_Driver/Inc/Legacy",
    "Middlewares/ST/STM32_Network_Library/Includes",
    "Middlewares/ST/STM32_USB_Device_Library/Class/AUDIO/Inc",
    "Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc",
    "Middlewares/ST/STM32_USB_Device_Library/Class/CustomHID/Inc",
    "Middlewares/ST/STM32_USB_Device_Library/Class/DFU/Inc",
    "Middlewares/ST/STM32_USB_Device_Library/Class/HID/Inc",
    "Middlewares/ST/STM32_USB_Device_Library/Class/MSC/Inc",
    "Middlewares/ST/STM32_USB_Device_Library/Core/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Class/AUDIO/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Class/CDC/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Class/HID/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Class/MTP/Inc",
    "Middlewares/ST/STM32_USB_Host_Library/Core/Inc",
    "Middlewares/Third_Party/FatFs/src",
    "Middlewares/Third_Party/FatFs/src/drivers",
    "Middlewares/Third_Party/LwIP/system/arch",
    "Middlewares/Third_Party/mbedTLS/include/mbedtls",
    "Middlewares/Third_Party/mbedTLS/include",
]

CMSIS_GLOB_EXCLUSIONS = [
    "**/IAR/**",
    "Drivers/CMSIS/Core_A/**",
    "Drivers/CMSIS/NN/**",
    "Drivers/CMSIS/DSP/**",
    "Drivers/CMSIS/RTOS2/**",
]

STM32_DEFINES = {
    "stm32f103xx" : [
        "USE_HAL_DRIVER",
        "STM32F103xx"
    ]

}


def stm32f1_startup_file(device):
    return "@stm32f1cube//Drivers/CMSIS/Device/ST/STM32F1xx/Source/Templates/gcc/startup_" + device + ".s"

def stm32f1_project(name, config):
    include_directories = INCLUDE_DIRECTORIES
    defines = []
    glob_excludes = ["**/*template.c"]

    cc_library(
        name = name + "_hal_driver",
        srcs = native.glob(["Drivers/STM32F1xx_HAL_Driver/**/*.c"], exclude = glob_excludes),
        hdrs = native.glob(["**/*.h"]),
        copts = ["-include stdint.h"],
        defines = defines,
        includes = include_directories,
        deps = [config],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_stm32_network_library",
        srcs = native.glob(["Middlewares/ST/STM32_Network_Library/**/*.c"], exclude = glob_excludes),
        hdrs = native.glob(["**/*.h"]),
        defines = defines,
        includes = include_directories,
        deps = [config],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_stm32_usb_device_library",
        srcs = native.glob(["MiddleWares/ST/STM32_USB_Device_Library/**/*.c"], exclude = glob_excludes),
        hdrs = native.glob(["**/*.h"]),
        defines = defines,
        includes = include_directories,
        deps = [config],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_stm32_usb_host_library",
        srcs = native.glob(["MiddleWares/ST/STM32_USB_Host_Library/**/*.c"], exclude = glob_excludes),
        hdrs = native.glob(["**/*.h"]),
        defines = defines,
        includes = include_directories,
        deps = [config],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_st_middlewares",
        deps = [
            ":" + name + "_stm32_network_library",
            ":" + name + "_stm32_usb_device_library",
            ":" + name + "_stm32_usb_host_library",
        ],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_fatfs",
        srcs = native.glob(["Middlewares/Third_Party/FatFs/src/*.c"], exclude = glob_excludes),
        hdrs = native.glob(["Middlewares/Third_Party/FatFs/src/*.h"]),
        includes = include_directories,
        deps = [config],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_mbed_tls",
        srcs = native.glob(
            ["Middlewares/Third_Party/mbedTLS/library/*.c"],
            exclude = glob_excludes,
        ),
        hdrs = native.glob(["Middlewares/Third_Party/mbedTLS/include/mbedtls/*.h"]),
        copts = [
            '-DMBEDTLS_CONFIG_FILE=\\"mbedtls_conf.h\\"',
        ],
        includes = include_directories,
        deps = [config],
        tags = ["manual"],
        alwayslink = True,
    )

    cc_library(
        name = name + "_third_party_middlewares",
        deps = [
            ":" + name + "_fatfs",
            ":" + name + "_mbed_tls",
        ],
        tags = ["manual"],
        alwayslink = True,
    )
