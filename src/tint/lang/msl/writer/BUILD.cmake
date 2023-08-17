# Copyright 2023 The Tint Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

################################################################################
# File generated by tools/src/cmd/gen
# using the template:
#   tools/src/cmd/gen/build/BUILD.cmake.tmpl
#
# Do not modify this file directly
################################################################################

include(lang/msl/writer/ast_printer/BUILD.cmake)
include(lang/msl/writer/common/BUILD.cmake)
include(lang/msl/writer/printer/BUILD.cmake)
include(lang/msl/writer/raise/BUILD.cmake)

if(TINT_BUILD_MSL_WRITER)
################################################################################
# CMake target: 'tint_lang_msl_writer'
################################################################################
tint_add_target("lang/msl/writer"
  lang/msl/writer/output.cc
  lang/msl/writer/output.h
  lang/msl/writer/writer.cc
  lang/msl/writer/writer.h
)

tint_target_add_dependencies("lang/msl/writer"
  "api/common"
  "api/options"
  "lang/core"
  "lang/core/constant"
  "lang/core/type"
  "lang/msl/writer/raise"
  "lang/wgsl/ast"
  "lang/wgsl/program"
  "lang/wgsl/sem"
  "utils/containers"
  "utils/diagnostic"
  "utils/generator"
  "utils/ice"
  "utils/id"
  "utils/macros"
  "utils/math"
  "utils/memory"
  "utils/reflection"
  "utils/result"
  "utils/rtti"
  "utils/symbol"
  "utils/text"
  "utils/traits"
)

if (TINT_BUILD_IR)
  tint_target_add_dependencies("lang/msl/writer"
    "lang/core/ir"
    "lang/wgsl/reader/program_to_ir"
  )
endif(TINT_BUILD_IR)

if (TINT_BUILD_MSL_WRITER)
  tint_target_add_dependencies("lang/msl/writer"
    "lang/msl/writer/ast_printer"
    "lang/msl/writer/common"
  )
endif(TINT_BUILD_MSL_WRITER)

if (TINT_BUILD_MSL_WRITER  AND  TINT_BUILD_IR)
  tint_target_add_dependencies("lang/msl/writer"
    "lang/msl/writer/printer"
  )
endif(TINT_BUILD_MSL_WRITER  AND  TINT_BUILD_IR)

endif(TINT_BUILD_MSL_WRITER)
if(TINT_BUILD_MSL_WRITER)
################################################################################
# CMake target: 'tint_lang_msl_writer_bench'
################################################################################
tint_add_target("lang/msl/writer:bench"
  lang/msl/writer/writer_bench.cc
)

tint_target_add_dependencies("lang/msl/writer:bench"
  "api/common"
  "api/options"
  "cmd/bench"
  "lang/core"
  "lang/core/constant"
  "lang/core/type"
  "lang/wgsl/ast"
  "lang/wgsl/program"
  "lang/wgsl/sem"
  "utils/containers"
  "utils/diagnostic"
  "utils/ice"
  "utils/id"
  "utils/macros"
  "utils/math"
  "utils/memory"
  "utils/reflection"
  "utils/result"
  "utils/rtti"
  "utils/symbol"
  "utils/text"
  "utils/traits"
)

if (TINT_BUILD_MSL_WRITER)
  tint_target_add_dependencies("lang/msl/writer:bench"
    "lang/msl/writer"
    "lang/msl/writer/common"
  )
endif(TINT_BUILD_MSL_WRITER)

endif(TINT_BUILD_MSL_WRITER)