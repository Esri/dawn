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

include(lang/wgsl/ast/BUILD.cmake)
include(lang/wgsl/helpers/BUILD.cmake)
include(lang/wgsl/inspector/BUILD.cmake)
include(lang/wgsl/program/BUILD.cmake)
include(lang/wgsl/reader/BUILD.cmake)
include(lang/wgsl/resolver/BUILD.cmake)
include(lang/wgsl/sem/BUILD.cmake)
include(lang/wgsl/writer/BUILD.cmake)

################################################################################
# CMake target: 'tint_lang_wgsl_test'
################################################################################
tint_add_target("lang/wgsl:test"
  lang/wgsl/wgsl_test.cc
)

tint_target_add_dependencies("lang/wgsl:test"
  "api/common"
  "lang/core"
  "lang/core/constant"
  "lang/core/type"
  "lang/wgsl/ast"
  "lang/wgsl/helpers:test"
  "lang/wgsl/program"
  "lang/wgsl/reader"
  "lang/wgsl/resolver"
  "lang/wgsl/sem"
  "lang/wgsl/writer"
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

tint_target_add_external_dependencies("lang/wgsl:test"
  "gtest"
)

if (TINT_BUILD_IR)
  tint_target_add_dependencies("lang/wgsl:test"
    "lang/core/ir"
    "lang/wgsl/reader/program_to_ir"
    "lang/wgsl/writer/ir_to_program"
  )
endif(TINT_BUILD_IR)

if (TINT_BUILD_WGSL_READER  AND  TINT_BUILD_WGSL_WRITER  AND  TINT_BUILD_IR)
  tint_target_add_sources("lang/wgsl:test"
    "lang/wgsl/ir_roundtrip_test.cc"
  )
endif(TINT_BUILD_WGSL_READER  AND  TINT_BUILD_WGSL_WRITER  AND  TINT_BUILD_IR)