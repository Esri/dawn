// Copyright 2023 The Tint Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "src/tint/lang/spirv/ir/intrinsic_call.h"
#include "gmock/gmock.h"
#include "gtest/gtest-spi.h"
#include "src/tint/lang/core/ir/ir_helper_test.h"

namespace tint::spirv::ir {
namespace {

using namespace tint::core::number_suffixes;  // NOLINT
using IR_IntrinsicCallTest = core::ir::IRTestHelper;

TEST_F(IR_IntrinsicCallTest, Usage) {
    auto* arg1 = b.Constant(1_u);
    auto* arg2 = b.Constant(2_u);
    auto* intrinsic =
        b.Call<spirv::ir::IntrinsicCall>(mod.Types().f32(), Intrinsic::kSelect, arg1, arg2);

    ASSERT_TRUE(intrinsic->Is<IntrinsicCall>());
    EXPECT_THAT(arg1->Usages(), testing::UnorderedElementsAre(core::ir::Usage{intrinsic, 0u}));
    EXPECT_THAT(arg2->Usages(), testing::UnorderedElementsAre(core::ir::Usage{intrinsic, 1u}));
}

TEST_F(IR_IntrinsicCallTest, Result) {
    auto* arg1 = b.Constant(1_u);
    auto* arg2 = b.Constant(2_u);
    auto* intrinsic =
        b.Call<spirv::ir::IntrinsicCall>(mod.Types().f32(), Intrinsic::kSelect, arg1, arg2);

    ASSERT_TRUE(intrinsic->Is<IntrinsicCall>());
    EXPECT_TRUE(intrinsic->HasResults());
    EXPECT_FALSE(intrinsic->HasMultiResults());
    EXPECT_TRUE(intrinsic->Result()->Is<core::ir::InstructionResult>());
    EXPECT_EQ(intrinsic->Result()->Source(), intrinsic);
}

TEST_F(IR_IntrinsicCallTest, Fail_NullType) {
    EXPECT_FATAL_FAILURE(
        {
            core::ir::Module mod;
            core::ir::Builder b{mod};
            b.Call<spirv::ir::IntrinsicCall>(nullptr, Intrinsic::kSelect);
        },
        "");
}

}  // namespace
}  // namespace tint::spirv::ir