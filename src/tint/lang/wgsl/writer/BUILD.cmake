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

include(lang/wgsl/writer/ast_printer/BUILD.cmake)
include(lang/wgsl/writer/ir_to_program/BUILD.cmake)
include(lang/wgsl/writer/syntax_tree_printer/BUILD.cmake)

################################################################################
# CMake target: 'tint_lang_wgsl_writer'
################################################################################
tint_add_target("lang/wgsl/writer"
  lang/wgsl/writer/options.cc
  lang/wgsl/writer/options.h
  lang/wgsl/writer/output.cc
  lang/wgsl/writer/output.h
  lang/wgsl/writer/writer.cc
  lang/wgsl/writer/writer.h
)

tint_target_add_dependencies("lang/wgsl/writer"
  "lang/core"
  "lang/core/constant"
  "lang/core/type"
  "lang/wgsl/ast"
  "lang/wgsl/program"
  "lang/wgsl/sem"
  "lang/wgsl/writer/ast_printer"
  "lang/wgsl/writer/syntax_tree_printer"
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

################################################################################
# CMake target: 'tint_lang_wgsl_writer_bench'
################################################################################
tint_add_target("lang/wgsl/writer:bench"
  lang/wgsl/writer/writer_bench.cc
)

tint_target_add_dependencies("lang/wgsl/writer:bench"
  "cmd/bench"
  "lang/core"
  "lang/core/constant"
  "lang/core/type"
  "lang/wgsl/ast"
  "lang/wgsl/program"
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