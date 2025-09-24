# Copyright Contributors to the OpenImageIO project.
# SPDX-License-Identifier: Apache-2.0
# https://github.com/AcademySoftwareFoundation/OpenImageIO

######################################################################
# GIF/GIFLIB
######################################################################

macro (build_dependency_with_cmakelist_template pkgname)
    cmake_parse_arguments(_pkg   # prefix
        # noValueKeywords:
        "NOINSTALL"
        # singleValueKeywords:
        "GIT_REPOSITORY;GIT_TAG;VERSION;SOURCE_SUBDIR;CMAKELISTS_TEMPLATE"
        # multiValueKeywords:
        "CMAKE_ARGS"
        # argsToParse:
        ${ARGN})

    message (STATUS "Building local ${pkgname} ${_pkg_VERSION} from ${_pkg_GIT_REPOSITORY}")

    set (${pkgname}_LOCAL_SOURCE_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}")
    set (${pkgname}_LOCAL_BUILD_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/${pkgname}-build")
    set (${pkgname}_LOCAL_INSTALL_DIR "${${PROJECT_NAME}_LOCAL_DEPS_ROOT}/dist")
    message (STATUS "Downloading local ${_pkg_GIT_REPOSITORY}")

    set (_pkg_quiet OUTPUT_QUIET)

    # Clone the repo if we don't already have it
    find_package (Git REQUIRED)
    if (NOT IS_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})
        execute_process(COMMAND ${GIT_EXECUTABLE} clone ${_pkg_GIT_REPOSITORY}
                                -b ${_pkg_GIT_TAG} --depth 1 -q
                                ${${pkgname}_LOCAL_SOURCE_DIR}
                        ${_pkg_quiet})
        if (NOT IS_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR})
            message (FATAL_ERROR "Could not download ${_pkg_GIT_REPOSITORY}")
        endif ()
    endif ()
    execute_process(COMMAND ${GIT_EXECUTABLE} checkout ${_pkg_GIT_TAG}
                    WORKING_DIRECTORY ${${pkgname}_LOCAL_SOURCE_DIR}
                    ${_pkg_quiet})

    # add the CMakeLists.txt if specified
    if (_pkg_CMAKELISTS_TEMPLATE)
        message(STATUS "Adding custom CMakeLists.txt for ${pkgname}")
        configure_file(${_pkg_CMAKELISTS_TEMPLATE} 
                      "${${pkgname}_LOCAL_SOURCE_DIR}/${_pkg_SOURCE_SUBDIR}/CMakeLists.txt"
                      @ONLY)
    endif()

    # Configure the package
    if (${PROJECT_NAME}_DEPENDENCY_BUILD_VERBOSE)
        set (_pkg_cmake_verbose -DCMAKE_VERBOSE_MAKEFILE=ON
                                -DCMAKE_MESSAGE_LOG_LEVEL=VERBOSE
                                -DCMAKE_RULE_MESSAGES=ON
                                )
    else ()
        set (_pkg_cmake_verbose -DCMAKE_VERBOSE_MAKEFILE=OFF
                                -DCMAKE_MESSAGE_LOG_LEVEL=ERROR
                                -DCMAKE_RULE_MESSAGES=OFF
                                -Wno-dev
                                )
    endif ()

    # Make sure to inherit CMAKE_IGNORE_PATH
    set(_pkg_CMAKE_ARGS ${_pkg_CMAKE_ARGS} ${_pkg_CMAKE_ARGS})
    if (CMAKE_IGNORE_PATH)
        string(REPLACE ";" "\\;" CMAKE_IGNORE_PATH_ESCAPED "${CMAKE_IGNORE_PATH}")
        list(APPEND _pkg_CMAKE_ARGS "-DCMAKE_IGNORE_PATH=${CMAKE_IGNORE_PATH_ESCAPED}")
    endif()

    # Pass along any CMAKE_MSVC_RUNTIME_LIBRARY
    if (WIN32 AND CMAKE_MSVC_RUNTIME_LIBRARY)
        list (APPEND _pkg_CMAKE_ARGS -DCMAKE_MSVC_RUNTIME_LIBRARY=${CMAKE_MSVC_RUNTIME_LIBRARY})
    endif ()

    execute_process (COMMAND
        ${CMAKE_COMMAND}
            # Put things in our special local build areas
                -S ${${pkgname}_LOCAL_SOURCE_DIR}/${_pkg_SOURCE_SUBDIR}
                -B ${${pkgname}_LOCAL_BUILD_DIR}
                -DCMAKE_INSTALL_PREFIX=${${pkgname}_LOCAL_INSTALL_DIR}
            # Same build type as us
                -DCMAKE_BUILD_TYPE=${${PROJECT_NAME}_DEPENDENCY_BUILD_TYPE}
            # Shhhh
                -DCMAKE_MESSAGE_INDENT="        "
                -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF
                ${_pkg_cmake_verbose}
            # Build args passed by caller
                ${_pkg_CMAKE_ARGS}
        ${pkg_quiet}
        )

    # Build the package
    execute_process (COMMAND ${CMAKE_COMMAND}
                        --build ${${pkgname}_LOCAL_BUILD_DIR}
                        --config ${${PROJECT_NAME}_DEPENDENCY_BUILD_TYPE}
                     ${pkg_quiet}
                    )

    # Install the project, unless instructed not to do so
    if (NOT _pkg_NOINSTALL)
        execute_process (COMMAND ${CMAKE_COMMAND}
                            --build ${${pkgname}_LOCAL_BUILD_DIR}
                            --config ${${PROJECT_NAME}_DEPENDENCY_BUILD_TYPE}
                            --target install
                         ${pkg_quiet}
                        )
        set (${pkgname}_ROOT ${${pkgname}_LOCAL_INSTALL_DIR})
        list (APPEND CMAKE_PREFIX_PATH ${${pkgname}_LOCAL_INSTALL_DIR})
    endif ()
endmacro ()


set_cache (GIF_BUILD_VERSION "5.2.1" "GIFLIB version for local builds")
super_set (GIF_BUILD_GIT_REPOSITORY "https://git.code.sf.net/p/giflib/code")
super_set (GIF_BUILD_GIT_TAG "${GIF_BUILD_VERSION}")


set_cache (GIF_BUILD_SHARED_LIBS ${LOCAL_BUILD_SHARED_LIBS_DEFAULT}
           DOC "Should execute a local GIFLIB build; if necessary, build shared libraries" ADVANCED)

string (MAKE_C_IDENTIFIER ${GIF_BUILD_VERSION} GIF_VERSION_IDENT)

build_dependency_with_cmakelist_template(GIF
    VERSION         ${GIF_BUILD_VERSION}
    GIT_REPOSITORY  ${GIF_BUILD_GIT_REPOSITORY}
    GIT_TAG         ${GIF_BUILD_GIT_TAG}
    CMAKELISTS_TEMPLATE "${CMAKE_CURRENT_LIST_DIR}/build_GIF_CMakeLists.txt"
    CMAKE_ARGS
        -D BUILD_SHARED_LIBS=${GIF_BUILD_SHARED_LIBS}
)

# verify that the install happened, else print success
set (GIF_ROOT ${GIF_LOCAL_INSTALL_DIR})

# Signal to caller that we need to find again at the installed location
set (GIF_REFIND TRUE)
set (GIF_REFIND_VERSION ${GIF_BUILD_VERSION})
set (GIF_REFIND_ARGS CONFIG)

if (GIF_BUILD_SHARED_LIBS)
    install_local_dependency_libs (GIF GIF)
endif ()
