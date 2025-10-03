# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO

######################################################################
# GIF/GIFLIB
# The original library does not have a CMake build system, so we
# provide our own CMakeLists.txt template to build it.
# See build_GIF_CMakeLists.txt for details.
######################################################################

set_cache (GIF_BUILD_VERSION "5.2.1" "GIFLIB version for local builds")
super_set (GIF_BUILD_GIT_REPOSITORY "https://git.code.sf.net/p/giflib/code")
super_set (GIF_BUILD_GIT_TAG "${GIF_BUILD_VERSION}")
set_cache (GIF_BUILD_SHARED_LIBS ${LOCAL_BUILD_SHARED_LIBS_DEFAULT}
           DOC "Should execute a local GIFLIB build; if necessary, build shared libraries" ADVANCED)

# string (MAKE_C_IDENTIFIER ${GIF_BUILD_VERSION} GIF_VERSION_IDENT)

# build_dependency_with_cmake(GIF
#     VERSION         ${GIF_BUILD_VERSION}
#     GIT_REPOSITORY  ${GIF_BUILD_GIT_REPOSITORY}
#     GIT_TAG         ${GIF_BUILD_GIT_TAG}
#     # pass the path to our custom CMakeLists.txt template
#     CMAKELISTS_TEMPLATE "${CMAKE_CURRENT_LIST_DIR}/build_GIF_CMakeLists.txt"
#     CMAKE_ARGS
#         -D BUILD_SHARED_LIBS=${GIF_BUILD_SHARED_LIBS}
# )

# # Set some things up that we'll need for a subsequent find_package to work
# set (GIF_ROOT ${GIF_LOCAL_INSTALL_DIR})

# find_package(GIF REQUIRED CONFIG PATHS "D:/a/OpenImageIO/OpenImageIO/build/deps/dist/lib/cmake")
# message(STATUS "GIF found at ${GIF_DIR}")

# # Signal to caller that we need to find again at the installed location
# set (GIF_REFIND TRUE)
# set (GIF_REFIND_VERSION ${GIF_BUILD_VERSION})
# set (GIF_REFIND_ARGS CONFIG)

# if (GIF_BUILD_SHARED_LIBS)
#     install_local_dependency_libs (GIF GIF)
# endif ()
