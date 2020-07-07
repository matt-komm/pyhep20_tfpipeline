#[[===================================================================
Copyright 2019 Matthias Komm, Vilius Cepaitis, Robert Bainbridge, 
Alex Tapper, Oliver Buchmueller. All Rights Reserved. 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
    
Unless required by applicable law or agreed to in writing, 
software distributed under the License is distributed on an "AS IS" 
BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express 
or implied.See the License for the specific language governing 
permissions and limitations under the License.
===================================================================]]


MESSAGE(STATUS "Looking for TensorFlow...")
include(FindPackageHandleStandardArgs)
unset(TENSORFLOW_FOUND)

execute_process(
	COMMAND ${PYTHON_EXECUTABLE} -c "from __future__ import print_function; import tensorflow as tf; print('tf_version',tf.__version__)"
    OUTPUT_VARIABLE TF_VER
    ERROR_VARIABLE TF_VER
    RESULT_VARIABLE TF_VER_OK
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "tf_version (.*)" _ ${TF_VER})
set(TF_VER ${CMAKE_MATCH_1})


string(REPLACE "." ";" VERSION_LIST ${TF_VER})
list(GET VERSION_LIST 0 TF_VER_MAJOR)
list(GET VERSION_LIST 1 TF_VER_MINOR)
list(GET VERSION_LIST 2 TF_VER_PATCH)

message(STATUS "Tensorflow version: " ${TF_VER_MAJOR}.${TF_VER_MINOR}.${TF_VER_PATCH})

execute_process(
	COMMAND ${PYTHON_EXECUTABLE} -c "from __future__ import print_function; import tensorflow as tf; print('tf_includepath',tf.sysconfig.get_include())"
    OUTPUT_VARIABLE TF_INC
    ERROR_VARIABLE TF_INC
    RESULT_VARIABLE TF_INC_OK
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "tf_includepath (.*)" _ ${TF_INC})
set(TF_INC ${CMAKE_MATCH_1})

if (${TF_INC_OK} EQUAL 0)
    find_path(TensorFlow_INCLUDE_DIR
        NAMES tensorflow/core/framework/op.h
        PATHS ${TF_INC}
        NO_DEFAULT_PATH
    )
endif (${TF_INC_OK} EQUAL 0)

message(STATUS "Tensorflow include path: ${TensorFlow_INCLUDE_DIR}")

execute_process(
	COMMAND ${PYTHON_EXECUTABLE} -c "from __future__ import print_function; import tensorflow as tf; print('use ABI0','True' if '-D_GLIBCXX_USE_CXX11_ABI=0' in tf.sysconfig.get_compile_flags() else 'False')"
    OUTPUT_VARIABLE TF_FORCEABI
    ERROR_VARIABLE TF_FORCEABI
    RESULT_VARIABLE TF_FORCEABI_OK
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "use ABI0 (.*)" _ ${TF_FORCEABI})
set(TF_FORCEABI ${CMAKE_MATCH_1})

if (TF_FORCEABI STREQUAL "True")
    set(TF_DEFINITIONS "-D_GLIBCXX_USE_CXX11_ABI=0")
    message(STATUS "Force ABI: GLIBCXX_USE_CXX11_ABI=0")
else (TF_FORCEABI STREQUAL "True")
    set(TF_DEFINITIONS "")
endif (TF_FORCEABI STREQUAL "True")


execute_process(
    COMMAND ${PYTHON_EXECUTABLE} -c "from __future__ import print_function; import tensorflow as tf; print('tf_libpath',tf.sysconfig.get_lib())"
    OUTPUT_VARIABLE TF_LIB
    ERROR_VARIABLE TF_LIB
    RESULT_VARIABLE TF_LIB_OK
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "tf_libpath (.*)" _ ${TF_LIB})
set(TF_LIB ${CMAKE_MATCH_1})

message(STATUS "Tensorflow lib path: ${TF_LIB}")
if (${TF_LIB_OK} EQUAL 0)
    find_library(TensorFlow_LIBRARY 
            NAMES tensorflow_framework
            PATHS ${TF_LIB}
    )
endif (${TF_LIB_OK} EQUAL 0)

find_package_handle_standard_args(TensorFlow DEFAULT_MSG TensorFlow_INCLUDE_DIR TensorFlow_LIBRARY)

if(TENSORFLOW_FOUND)
    set(TensorFlow_LIBRARIES ${TensorFlow_LIBRARY})
    set(TensorFlow_INCLUDE_DIRS ${TensorFlow_INCLUDE_DIR} ${TensorFlow_INCLUDE_DIR}/external/nsync/public) #fix: https://github.com/sadeepj/crfasrnn_keras/issues/19
    set(TensorFlow_DEFINITIONS ${TF_DEFINITIONS})
endif()

mark_as_advanced(TensorFlow_INCLUDE_DIR TensorFlow_LIBRARY)

