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

if(TINT_BUILD_MSL_WRITER)
################################################################################
# CMake target: 'tint_lang_msl_validate'
################################################################################
tint_add_target("lang/msl/validate"
  lang/msl/validate/msl.cc
  lang/msl/validate/val.h
)

tint_target_add_dependencies("lang/msl/validate"
  "lang/core"
  "lang/core/constant"
  "lang/core/type"
  "lang/wgsl/ast"
  "lang/wgsl/program"
  "lang/wgsl/sem"
  "utils/command"
  "utils/containers"
  "utils/diagnostic"
  "utils/file"
  "utils/ice"
  "utils/id"
  "utils/macros"
  "utils/math"
  "utils/memory"
  "utils/result"
  "utils/rtti"
  "utils/symbol"
  "utils/text"
  "utils/traits"
)

endif(TINT_BUILD_MSL_WRITER)