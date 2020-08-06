load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_import", "cc_library")

def windows_dll(
        name_prefix,
        srcs = [],
        deps = [],
        hdrs = [],
        visibility = None,
        **kwargs):
    dll_name = name_prefix + ".dll"
    import_lib_name = name_prefix + "_import_lib"
    import_target_name = name_prefix + "_dll_import"

    # Build the shared library
    cc_binary(
        name = dll_name,
        srcs = srcs + hdrs,
        deps = deps,
        linkshared = 1,
        visibility = visibility,
        **kwargs
    )

    # Get the import library for the dll
    native.filegroup(
        name = import_lib_name,
        srcs = [":" + dll_name],
        output_group = "interface_library",
    )

    # Because we cannot directly depend on cc_binary from other cc rules in deps attribute,
    # we use cc_import as a bridge to depend on the dll.
    cc_import(
        name = import_target_name,
        interface_library = ":" + import_lib_name,
        shared_library = ":" + dll_name,
        visibility = visibility,
    )

    # Create a new cc_library to also include the headers needed for the shared library
    cc_library(
        name = name_prefix,
        hdrs = hdrs,
        visibility = visibility,
        deps = deps + [
            ":" + import_target_name,
        ],
    )
