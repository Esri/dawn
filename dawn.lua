project "dawn"

dofile(_BUILD_DIR .. "/static_library.lua")

configuration { "*" }

uuid "B737C74D-7147-4E95-8B6B-A0193894E8F7"

local DAWN_SRC_DIR = _3RDPARTY_DIR .. "/dawn"

--
-- Generation
--
local DAWN_GEN_OUTPUT_DIR = DAWN_SRC_DIR.."/out/gen"
local PYTHON_EXE = "/usr/local/rtc/python/3.8/bin/python"
if (os.is("windows")) then
  PYTHON_EXE = "C:/rtc/python/3.8/Scripts/python"
end

-- version based utilities
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_version_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --dawn-dir "..DAWN_SRC_DIR)

-- GPU info utilities
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_gpu_info_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --gpu-info-json "..DAWN_SRC_DIR.."/src/dawn/gpu_info.json")

-- native utilities
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_json_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --dawn-json "..DAWN_SRC_DIR.."/src/dawn/dawn.json --wire-json "..DAWN_SRC_DIR.."/src/dawn/dawn_wire.json --targets native_utils")

-- native WebGPU procs
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_json_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --dawn-json "..DAWN_SRC_DIR.."/src/dawn/dawn.json --wire-json "..DAWN_SRC_DIR.."/src/dawn/dawn_wire.json --targets webgpu_dawn_native_proc")

-- headers
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_json_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --dawn-json "..DAWN_SRC_DIR.."/src/dawn/dawn.json --wire-json "..DAWN_SRC_DIR.."/src/dawn/dawn_wire.json --targets headers")

-- C++ headers
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_json_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --dawn-json "..DAWN_SRC_DIR.."/src/dawn/dawn.json --wire-json "..DAWN_SRC_DIR.."/src/dawn/dawn_wire.json --targets cpp_headers")

-- WebGPU headers
os.execute(PYTHON_EXE.." "..DAWN_SRC_DIR.."/generator/dawn_json_generator.py --template-dir "..DAWN_SRC_DIR.."/generator/templates --root-dir "..DAWN_SRC_DIR.." --output-dir "..DAWN_GEN_OUTPUT_DIR.." --dawn-json "..DAWN_SRC_DIR.."/src/dawn/dawn.json --wire-json "..DAWN_SRC_DIR.."/src/dawn/dawn_wire.json --targets webgpu_headers")

--
-- Configure platforms
--

-- Platforms
local enable_android = false
local enable_apple = false
local enable_linux = false
local enable_win = false

-- Shader languages
local enable_glsl = false
local enable_hlsl = false
local enable_msl = false
local enable_spirv = false

-- GPU backends
local enable_d3d12 = false
local enable_metal = false
local enable_vulkan = false
local enable_null = false -- Fail silently when no native GPU API is available?

if (_PLATFORM_ANDROID) then

  enable_android = true
  enable_spirv = true
  enable_vulkan = true

end

if (_PLATFORM_IOS) then

  enable_apple = true
  enable_metal = true
  enable_msl = true

end

if (_PLATFORM_LINUX) then

  enable_linux = true
  enable_spirv = true
  enable_vulkan = true

end

if (_PLATFORM_MACOS) then

  enable_apple = true
  enable_metal = true
  enable_msl = true

end

if (_PLATFORM_WINDOWS) then

  enable_d3d12 = true
  enable_hlsl = true
  enable_spirv = true
  enable_vulkan = true
  enable_win = true

end

if (_PLATFORM_WINUWP) then

  -- not supported

end

--
-- Common settings
--

defines {
  "DAWN_NATIVE_IMPLEMENTATION",
  "TINT_BUILD_WGSL_READER=1",
  "TINT_BUILD_WGSL_WRITER=1",
}

includedirs {
  ".",
  DAWN_GEN_OUTPUT_DIR.."/include",
  "include",
  DAWN_GEN_OUTPUT_DIR.."/src",
  "src",
  "src/dawn/partition_alloc",

  _3RDPARTY_DIR .. "/abseil-cpp",
}

-- Tip
-- The Dawn library contains many source files that have the same name.
-- This confuses the premake/lua build system on windows currently used
-- by RTC, which assumes each translation unit has a unique file
-- name, discarding the leading path.
--
-- E.g. both the following source files lead to a .o file written to
-- to the same output location. One will overwrite the other.
--
--   "src/tint/lang/core/ir/function.cc",
--   "src/tint/lang/wgsl/ast/function_rtc_shim1.cc",
--
-- To remedy this, the runtimecore branch introduces "shim" files with
-- unique names which simply include the original. We build the shim file
-- which results in uniquely named .o files.
--
-- E.g.:
--
--   "src/tint/lang/core/ir/function.cc",
--   "src/tint/lang/wgsl/ast/function_rtc_shim1.cc",
--
-- where the content of "src/tint/lang/wgsl/ast/function_rtc_shim1.cc"
-- is simply:
--
--   #include "function.cc"
--
-- This conflict is case and suffix insensitive. E.g. the following files
-- lead to conflicting .o files:
--
--  "src/dawn/native/Texture.cpp",
--  "src/tint/lang/core/type/texture.cc",
--
-- The following command can help spot source files with duplicate
-- names within this file:
--
-- grep '\.c.*' dawn.lua | sed 's/^\ *\".*\/\([a-zA-Z0-9_]*\)\.[cp]*\"\,/\L\1/' | sort | uniq -d

files {
  -- src/dawn/native/
  DAWN_GEN_OUTPUT_DIR.."/src/dawn/native/**.cpp",
  "src/dawn/native/DawnNative.cpp",
  "src/dawn/native/Adapter.cpp",
  "src/dawn/native/ApplyClearColorValueWithDrawHelper.cpp",
  "src/dawn/native/AsyncTask.cpp",
  "src/dawn/native/AttachmentState.cpp",
  "src/dawn/native/BackendConnection.cpp",
  "src/dawn/native/BindGroup.cpp",
  "src/dawn/native/BindGroupLayout.cpp",
  "src/dawn/native/BindGroupLayoutInternal.cpp",
  "src/dawn/native/BindingInfo.cpp",
  "src/dawn/native/BlitBufferToDepthStencil.cpp",
  "src/dawn/native/BlitColorToColorWithDraw.cpp",
  "src/dawn/native/BlitDepthToDepth.cpp",
  "src/dawn/native/BlitTextureToBuffer.cpp",
  "src/dawn/native/Blob.cpp",
  "src/dawn/native/BlobCache.cpp",
  "src/dawn/native/BuddyAllocator.cpp",
  "src/dawn/native/BuddyMemoryAllocator.cpp",
  "src/dawn/native/Buffer.cpp",
  "src/dawn/native/CachedObject.cpp",
  "src/dawn/native/CacheKey.cpp",
  "src/dawn/native/CacheRequest.cpp",
  "src/dawn/native/CallbackTaskManager.cpp",
  "src/dawn/native/CommandAllocator.cpp",
  "src/dawn/native/CommandBuffer.cpp",
  "src/dawn/native/CommandBufferStateTracker.cpp",
  "src/dawn/native/CommandEncoder.cpp",
  "src/dawn/native/CommandValidation.cpp",
  "src/dawn/native/Commands.cpp",
  "src/dawn/native/CompilationMessages.cpp",
  "src/dawn/native/ComputePassEncoder.cpp",
  "src/dawn/native/ComputePipeline.cpp",
  "src/dawn/native/CopyTextureForBrowserHelper.cpp",
  "src/dawn/native/CreatePipelineAsyncEvent.cpp",
  "src/dawn/native/Device.cpp",
  "src/dawn/native/DynamicUploader.cpp",
  "src/dawn/native/EncodingContext.cpp",
  "src/dawn/native/Error.cpp",
  "src/dawn/native/ErrorData.cpp",
  "src/dawn/native/ErrorInjector.cpp",
  "src/dawn/native/ErrorScope.cpp",
  "src/dawn/native/EventManager.cpp",
  "src/dawn/native/Features.cpp",
  "src/dawn/native/ExternalTexture.cpp",
  "src/dawn/native/ExecutionQueue.cpp",
  "src/dawn/native/IndirectDrawMetadata.cpp",
  "src/dawn/native/IndirectDrawValidationEncoder.cpp",
  "src/dawn/native/ObjectContentHasher.cpp",
  "src/dawn/native/Format.cpp",
  "src/dawn/native/Instance.cpp",
  "src/dawn/native/InternalPipelineStore.cpp",
  "src/dawn/native/Limits.cpp",
  "src/dawn/native/SystemEvent.cpp",
  "src/dawn/native/SystemHandle.cpp",
  "src/dawn/native/ObjectBase.cpp",
  "src/dawn/native/PassResourceUsage.cpp",
  "src/dawn/native/PassResourceUsageTracker.cpp",
  "src/dawn/native/PerStage.cpp",
  "src/dawn/native/PhysicalDevice.cpp",
  "src/dawn/native/Pipeline.cpp",
  "src/dawn/native/PipelineCache.cpp",
  "src/dawn/native/PipelineLayout.cpp",
  "src/dawn/native/PooledResourceMemoryAllocator.cpp",
  "src/dawn/native/ProgrammableEncoder.cpp",
  "src/dawn/native/QueryHelper.cpp",
  "src/dawn/native/QuerySet.cpp",
  "src/dawn/native/Queue.cpp",
  "src/dawn/native/RenderBundle.cpp",
  "src/dawn/native/RenderBundleEncoder.cpp",
  "src/dawn/native/RenderEncoderBase.cpp",
  "src/dawn/native/RenderPassEncoder.cpp",
  "src/dawn/native/RenderPipeline.cpp",
  "src/dawn/native/ResourceMemoryAllocation.cpp",
  "src/dawn/native/RingBufferAllocator.cpp",
  "src/dawn/native/Sampler.cpp",
  "src/dawn/native/ScratchBuffer.cpp",
  "src/dawn/native/ShaderModule.cpp",
  "src/dawn/native/SharedBufferMemory.cpp",
  "src/dawn/native/SharedFence.cpp",
  "src/dawn/native/SharedResourceMemory.cpp",
  "src/dawn/native/SharedTextureMemory.cpp",
  "src/dawn/native/Subresource.cpp",
  "src/dawn/native/Surface.cpp",
  "src/dawn/native/SwapChain.cpp",
  "src/dawn/native/Texture.cpp",
  "src/dawn/native/TintUtils.cpp",
  "src/dawn/native/Toggles.cpp",
  "src/dawn/native/webgpu_absl_format.cpp",
  "src/dawn/native/stream/BlobSource.cpp",
  "src/dawn/native/stream/ByteVectorSink.cpp",
  "src/dawn/native/stream/Stream.cpp",
  "src/dawn/native/utils/WGPUHelpers.cpp",

  -- CMake target: dawn_common
  DAWN_GEN_OUTPUT_DIR.."/src/dawn/common/**.cpp",
  "src/dawn/common/AlignedAlloc.cpp",
  "src/dawn/common/Assert.cpp",
  "src/dawn/common/DynamicLib.cpp",
  "src/dawn/common/FutureUtils.cpp",
  "src/dawn/common/GPUInfo.cpp",
  "src/dawn/common/Log.cpp",
  "src/dawn/common/Math.cpp",
  "src/dawn/common/Mutex.cpp",
  "src/dawn/common/RefCounted.cpp",
  "src/dawn/common/Result.cpp",
  "src/dawn/common/SlabAllocator.cpp",
  "src/dawn/common/SystemUtils.cpp",
  "src/dawn/common/WeakRefSupport.cpp",

  -- CMake target: dawn_platform
  "src/dawn/platform/DawnPlatform.cpp",
  "src/dawn/platform/WorkerThread.cpp",
  "src/dawn/platform/metrics/HistogramMacros.cpp",
  "src/dawn/platform/tracing/EventTracer.cpp",

  -- CMake target: tint_api
  "src/tint/api/tint.cc",
  "src/tint/api/common/common.cc",
  "src/tint/api/options/options.cc",

  -- CMake target: tint_lang_core
  "src/tint/lang/core/access.cc",
  "src/tint/lang/core/address_space.cc",
  "src/tint/lang/core/attribute.cc",
  "src/tint/lang/core/binary_op.cc",
  "src/tint/lang/core/builtin_fn.cc",
  "src/tint/lang/core/builtin_type.cc",
  "src/tint/lang/core/builtin_value.cc",
  "src/tint/lang/core/interpolation_sampling.cc",
  "src/tint/lang/core/interpolation_type.cc",
  "src/tint/lang/core/number.cc",
  "src/tint/lang/core/parameter_usage.cc",
  "src/tint/lang/core/texel_format.cc",
  "src/tint/lang/core/unary_op.cc",
  "src/tint/lang/core/constant/composite.cc",
  "src/tint/lang/core/constant/eval.cc",
  "src/tint/lang/core/constant/invalid.cc",
  "src/tint/lang/core/constant/manager.cc",
  "src/tint/lang/core/constant/node.cc",
  "src/tint/lang/core/constant/scalar.cc",
  "src/tint/lang/core/constant/splat.cc",
  "src/tint/lang/core/constant/value.cc",
  "src/tint/lang/core/intrinsic/ctor_conv.cc",
  "src/tint/lang/core/intrinsic/data.cc",
  "src/tint/lang/core/intrinsic/table.cc",
  "src/tint/lang/core/ir/access_rtc_shim.cc",
  "src/tint/lang/core/ir/binary.cc",
  "src/tint/lang/core/ir/bitcast.cc",
  "src/tint/lang/core/ir/block.cc",
  "src/tint/lang/core/ir/block_param.cc",
  "src/tint/lang/core/ir/break_if.cc",
  "src/tint/lang/core/ir/builder.cc",
  "src/tint/lang/core/ir/builtin_call.cc",
  "src/tint/lang/core/ir/call.cc",
  "src/tint/lang/core/ir/clone_context.cc",
  "src/tint/lang/core/ir/constant.cc",
  "src/tint/lang/core/ir/construct.cc",
  "src/tint/lang/core/ir/continue.cc",
  "src/tint/lang/core/ir/control_instruction.cc",
  "src/tint/lang/core/ir/convert.cc",
  "src/tint/lang/core/ir/core_binary.cc",
  "src/tint/lang/core/ir/core_builtin_call.cc",
  "src/tint/lang/core/ir/core_unary.cc",
  "src/tint/lang/core/ir/disassembly.cc",
  "src/tint/lang/core/ir/discard.cc",
  "src/tint/lang/core/ir/exit.cc",
  "src/tint/lang/core/ir/exit_if.cc",
  "src/tint/lang/core/ir/exit_loop.cc",
  "src/tint/lang/core/ir/exit_switch.cc",
  "src/tint/lang/core/ir/function.cc",
  "src/tint/lang/core/ir/function_param.cc",
  "src/tint/lang/core/ir/if.cc",
  "src/tint/lang/core/ir/instruction.cc",
  "src/tint/lang/core/ir/instruction_result.cc",
  "src/tint/lang/core/ir/let.cc",
  "src/tint/lang/core/ir/load.cc",
  "src/tint/lang/core/ir/load_vector_element.cc",
  "src/tint/lang/core/ir/loop.cc",
  "src/tint/lang/core/ir/module.cc",
  "src/tint/lang/core/ir/multi_in_block.cc",
  "src/tint/lang/core/ir/next_iteration.cc",
  "src/tint/lang/core/ir/operand_instruction.cc",
  "src/tint/lang/core/ir/return.cc",
  "src/tint/lang/core/ir/store.cc",
  "src/tint/lang/core/ir/store_vector_element.cc",
  "src/tint/lang/core/ir/switch.cc",
  "src/tint/lang/core/ir/swizzle.cc",
  "src/tint/lang/core/ir/terminate_invocation.cc",
  "src/tint/lang/core/ir/terminator.cc",
  "src/tint/lang/core/ir/unary.cc",
  "src/tint/lang/core/ir/unreachable.cc",
  "src/tint/lang/core/ir/user_call.cc",
  "src/tint/lang/core/ir/validator.cc",
  "src/tint/lang/core/ir/value_rtc_shim.cc",
  "src/tint/lang/core/ir/var.cc",
  "src/tint/lang/core/ir/transform/add_empty_entry_point.cc",
  "src/tint/lang/core/ir/transform/array_length_from_uniform.cc",
  "src/tint/lang/core/ir/transform/bgra8unorm_polyfill.cc",
  "src/tint/lang/core/ir/transform/binary_polyfill.cc",
  "src/tint/lang/core/ir/transform/binding_remapper.cc",
  "src/tint/lang/core/ir/transform/block_decorated_structs.cc",
  "src/tint/lang/core/ir/transform/builtin_polyfill.cc",
  "src/tint/lang/core/ir/transform/combine_access_instructions.cc",
  "src/tint/lang/core/ir/transform/conversion_polyfill.cc",
  "src/tint/lang/core/ir/transform/demote_to_helper.cc",
  "src/tint/lang/core/ir/transform/direct_variable_access.cc",
  "src/tint/lang/core/ir/transform/multiplanar_external_texture.cc",
  "src/tint/lang/core/ir/transform/preserve_padding.cc",
  "src/tint/lang/core/ir/transform/robustness.cc",
  "src/tint/lang/core/ir/transform/shader_io.cc",
  "src/tint/lang/core/ir/transform/std140.cc",
  "src/tint/lang/core/ir/transform/value_to_let.cc",
  "src/tint/lang/core/ir/transform/vectorize_scalar_matrix_constructors.cc",
  "src/tint/lang/core/ir/transform/zero_init_workgroup_memory.cc",
  "src/tint/lang/core/ir/transform/common/referenced_module_vars.cc",
  "src/tint/lang/core/type/abstract_float.cc",
  "src/tint/lang/core/type/abstract_int.cc",
  "src/tint/lang/core/type/abstract_numeric.cc",
  "src/tint/lang/core/type/array.cc",
  "src/tint/lang/core/type/array_count.cc",
  "src/tint/lang/core/type/atomic.cc",
  "src/tint/lang/core/type/bool.cc",
  "src/tint/lang/core/type/builtin_structs.cc",
  "src/tint/lang/core/type/depth_multisampled_texture.cc",
  "src/tint/lang/core/type/depth_texture.cc",
  "src/tint/lang/core/type/external_texture.cc",
  "src/tint/lang/core/type/f16.cc",
  "src/tint/lang/core/type/f32.cc",
  "src/tint/lang/core/type/i32.cc",
  "src/tint/lang/core/type/input_attachment.cc",
  "src/tint/lang/core/type/invalid_rtc_shim.cc",
  "src/tint/lang/core/type/manager_rtc_shim1.cc",
  "src/tint/lang/core/type/matrix.cc",
  "src/tint/lang/core/type/memory_view.cc",
  "src/tint/lang/core/type/multisampled_texture.cc",
  "src/tint/lang/core/type/node_rtc_shim1.cc",
  "src/tint/lang/core/type/numeric_scalar.cc",
  "src/tint/lang/core/type/pointer.cc",
  "src/tint/lang/core/type/reference.cc",
  "src/tint/lang/core/type/sampled_texture.cc",
  "src/tint/lang/core/type/sampler_rtc_shim.cc",
  "src/tint/lang/core/type/sampler_kind.cc",
  "src/tint/lang/core/type/scalar_rtc_shim1.cc",
  "src/tint/lang/core/type/storage_texture.cc",
  "src/tint/lang/core/type/struct.cc",
  "src/tint/lang/core/type/texture_rtc_shim.cc",
  "src/tint/lang/core/type/texture_dimension.cc",
  "src/tint/lang/core/type/type.cc",
  "src/tint/lang/core/type/u32.cc",
  "src/tint/lang/core/type/unique_node.cc",
  "src/tint/lang/core/type/vector.cc",
  "src/tint/lang/core/type/void.cc",

  -- CMake target: tint_lang_wgsl
  "src/tint/lang/wgsl/builtin_fn_rtc_shim1.cc",
  "src/tint/lang/wgsl/diagnostic_rule.cc",
  "src/tint/lang/wgsl/diagnostic_severity.cc",
  "src/tint/lang/wgsl/extension.cc",
  "src/tint/lang/wgsl/ast/accessor_expression.cc",
  "src/tint/lang/wgsl/ast/alias.cc",
  "src/tint/lang/wgsl/ast/assignment_statement.cc",
  "src/tint/lang/wgsl/ast/attribute_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/binary_expression.cc",
  "src/tint/lang/wgsl/ast/binding_attribute.cc",
  "src/tint/lang/wgsl/ast/blend_src_attribute.cc",
  "src/tint/lang/wgsl/ast/block_statement.cc",
  "src/tint/lang/wgsl/ast/bool_literal_expression.cc",
  "src/tint/lang/wgsl/ast/break_if_statement.cc",
  "src/tint/lang/wgsl/ast/break_statement.cc",
  "src/tint/lang/wgsl/ast/builder_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/builtin_attribute.cc",
  "src/tint/lang/wgsl/ast/call_expression.cc",
  "src/tint/lang/wgsl/ast/call_statement.cc",
  "src/tint/lang/wgsl/ast/case_selector.cc",
  "src/tint/lang/wgsl/ast/case_statement.cc",
  "src/tint/lang/wgsl/ast/clone_context_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/color_attribute.cc",
  "src/tint/lang/wgsl/ast/compound_assignment_statement.cc",
  "src/tint/lang/wgsl/ast/const.cc",
  "src/tint/lang/wgsl/ast/const_assert.cc",
  "src/tint/lang/wgsl/ast/continue_statement.cc",
  "src/tint/lang/wgsl/ast/diagnostic_attribute.cc",
  "src/tint/lang/wgsl/ast/diagnostic_control.cc",
  "src/tint/lang/wgsl/ast/diagnostic_directive.cc",
  "src/tint/lang/wgsl/ast/diagnostic_rule_name.cc",
  "src/tint/lang/wgsl/ast/disable_validation_attribute.cc",
  "src/tint/lang/wgsl/ast/discard_statement.cc",
  "src/tint/lang/wgsl/ast/enable.cc",
  "src/tint/lang/wgsl/ast/expression.cc",
  "src/tint/lang/wgsl/ast/extension_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/float_literal_expression.cc",
  "src/tint/lang/wgsl/ast/for_loop_statement.cc",
  "src/tint/lang/wgsl/ast/function_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/group_attribute.cc",
  "src/tint/lang/wgsl/ast/id_attribute.cc",
  "src/tint/lang/wgsl/ast/identifier.cc",
  "src/tint/lang/wgsl/ast/identifier_expression.cc",
  "src/tint/lang/wgsl/ast/if_statement.cc",
  "src/tint/lang/wgsl/ast/increment_decrement_statement.cc",
  "src/tint/lang/wgsl/ast/index_accessor_expression.cc",
  "src/tint/lang/wgsl/ast/input_attachment_index_attribute.cc",
  "src/tint/lang/wgsl/ast/int_literal_expression.cc",
  "src/tint/lang/wgsl/ast/internal_attribute.cc",
  "src/tint/lang/wgsl/ast/interpolate_attribute.cc",
  "src/tint/lang/wgsl/ast/invariant_attribute.cc",
  "src/tint/lang/wgsl/ast/let_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/literal_expression.cc",
  "src/tint/lang/wgsl/ast/location_attribute.cc",
  "src/tint/lang/wgsl/ast/loop_statement.cc",
  "src/tint/lang/wgsl/ast/member_accessor_expression.cc",
  "src/tint/lang/wgsl/ast/module_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/must_use_attribute.cc",
  "src/tint/lang/wgsl/ast/node_rtc_shim2.cc",
  "src/tint/lang/wgsl/ast/override.cc",
  "src/tint/lang/wgsl/ast/parameter.cc",
  "src/tint/lang/wgsl/ast/phony_expression.cc",
  "src/tint/lang/wgsl/ast/pipeline_stage.cc",
  "src/tint/lang/wgsl/ast/requires.cc",
  "src/tint/lang/wgsl/ast/return_statement.cc",
  "src/tint/lang/wgsl/ast/stage_attribute.cc",
  "src/tint/lang/wgsl/ast/statement.cc",
  "src/tint/lang/wgsl/ast/stride_attribute.cc",
  "src/tint/lang/wgsl/ast/struct_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/struct_member.cc",
  "src/tint/lang/wgsl/ast/struct_member_align_attribute.cc",
  "src/tint/lang/wgsl/ast/struct_member_offset_attribute.cc",
  "src/tint/lang/wgsl/ast/struct_member_size_attribute.cc",
  "src/tint/lang/wgsl/ast/switch_statement.cc",
  "src/tint/lang/wgsl/ast/templated_identifier.cc",
  "src/tint/lang/wgsl/ast/type_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/type_decl.cc",
  "src/tint/lang/wgsl/ast/unary_op_expression.cc",
  "src/tint/lang/wgsl/ast/var_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/variable.cc",
  "src/tint/lang/wgsl/ast/variable_decl_statement.cc",
  "src/tint/lang/wgsl/ast/while_statement.cc",
  "src/tint/lang/wgsl/ast/workgroup_attribute.cc",
  "src/tint/lang/wgsl/ast/transform/add_block_attribute.cc",
  "src/tint/lang/wgsl/ast/transform/add_empty_entry_point_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/array_length_from_uniform_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/binding_remapper_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/builtin_polyfill_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/transform/canonicalize_entry_point_io.cc",
  "src/tint/lang/wgsl/ast/transform/clamp_frag_depth.cc",
  "src/tint/lang/wgsl/ast/transform/data_rtc_shim1.cc",
  "src/tint/lang/wgsl/ast/transform/demote_to_helper_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/direct_variable_access_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/disable_uniformity_analysis.cc",
  "src/tint/lang/wgsl/ast/transform/expand_compound_assignment.cc",
  "src/tint/lang/wgsl/ast/transform/first_index_offset.cc",
  "src/tint/lang/wgsl/ast/transform/fold_constants.cc",
  "src/tint/lang/wgsl/ast/transform/get_insertion_point.cc",
  "src/tint/lang/wgsl/ast/transform/hoist_to_decl_before.cc",
  "src/tint/lang/wgsl/ast/transform/manager_rtc_shim2.cc",
  "src/tint/lang/wgsl/ast/transform/multiplanar_external_texture_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/offset_first_index.cc",
  "src/tint/lang/wgsl/ast/transform/preserve_padding_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/promote_initializers_to_let.cc",
  "src/tint/lang/wgsl/ast/transform/promote_side_effects_to_decl.cc",
  "src/tint/lang/wgsl/ast/transform/push_constant_helper.cc",
  "src/tint/lang/wgsl/ast/transform/remove_continue_in_switch.cc",
  "src/tint/lang/wgsl/ast/transform/remove_phonies.cc",
  "src/tint/lang/wgsl/ast/transform/remove_unreachable_statements.cc",
  "src/tint/lang/wgsl/ast/transform/renamer.cc",
  "src/tint/lang/wgsl/ast/transform/robustness_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/simplify_pointers.cc",
  "src/tint/lang/wgsl/ast/transform/single_entry_point.cc",
  "src/tint/lang/wgsl/ast/transform/std140_rtc_shim.cc",
  "src/tint/lang/wgsl/ast/transform/substitute_override.cc",
  "src/tint/lang/wgsl/ast/transform/transform.cc",
  "src/tint/lang/wgsl/ast/transform/unshadow.cc",
  "src/tint/lang/wgsl/ast/transform/vectorize_scalar_matrix_initializers.cc",
  "src/tint/lang/wgsl/ast/transform/vertex_pulling.cc",
  "src/tint/lang/wgsl/ast/transform/zero_init_workgroup_memory_rtc_shim.cc",
  "src/tint/lang/wgsl/common/common_rtc_shim1.cc",
  "src/tint/lang/wgsl/features/language_feature.cc",
  "src/tint/lang/wgsl/features/status.cc",
  "src/tint/lang/wgsl/helpers/append_vector.cc",
  "src/tint/lang/wgsl/helpers/apply_substitute_overrides.cc",
  "src/tint/lang/wgsl/helpers/check_supported_extensions.cc",
  "src/tint/lang/wgsl/helpers/flatten_bindings.cc",
  "src/tint/lang/wgsl/inspector/entry_point.cc",
  "src/tint/lang/wgsl/inspector/inspector.cc",
  "src/tint/lang/wgsl/inspector/resource_binding.cc",
  "src/tint/lang/wgsl/inspector/scalar_rtc_shim2.cc",
  "src/tint/lang/wgsl/intrinsic/ctor_conv_rtc_shim.cc",
  "src/tint/lang/wgsl/intrinsic/data_rtc_shim2.cc",
  "src/tint/lang/wgsl/ir/builtin_call_rtc_shim1.cc",
  "src/tint/lang/wgsl/ir/unary_rtc_shim.cc",
  "src/tint/lang/wgsl/program/clone_context_rtc_shim2.cc",
  "src/tint/lang/wgsl/program/program.cc",
  "src/tint/lang/wgsl/program/program_builder.cc",
  "src/tint/lang/wgsl/reader/reader.cc",
  "src/tint/lang/wgsl/reader/lower/lower.cc",
  "src/tint/lang/wgsl/reader/parser/classify_template_args.cc",
  "src/tint/lang/wgsl/reader/parser/lexer.cc",
  "src/tint/lang/wgsl/reader/parser/parser.cc",
  "src/tint/lang/wgsl/reader/parser/token.cc",
  "src/tint/lang/wgsl/reader/program_to_ir/program_to_ir.cc",
  "src/tint/lang/wgsl/resolver/dependency_graph.cc",
  "src/tint/lang/wgsl/resolver/incomplete_type.cc",
  "src/tint/lang/wgsl/resolver/resolve.cc",
  "src/tint/lang/wgsl/resolver/resolver.cc",
  "src/tint/lang/wgsl/resolver/sem_helper.cc",
  "src/tint/lang/wgsl/resolver/uniformity.cc",
  "src/tint/lang/wgsl/resolver/unresolved_identifier.cc",
  "src/tint/lang/wgsl/resolver/validator_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/accessor_expression_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/array_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/array_count_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/behavior.cc",
  "src/tint/lang/wgsl/sem/block_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/break_if_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/builtin_enum_expression.cc",
  "src/tint/lang/wgsl/sem/builtin_fn_rtc_shim2.cc",
  "src/tint/lang/wgsl/sem/call_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/call_target.cc",
  "src/tint/lang/wgsl/sem/expression_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/for_loop_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/function_rtc_shim2.cc",
  "src/tint/lang/wgsl/sem/function_expression.cc",
  "src/tint/lang/wgsl/sem/if_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/index_accessor_expression_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/info.cc",
  "src/tint/lang/wgsl/sem/load_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/loop_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/materialize.cc",
  "src/tint/lang/wgsl/sem/member_accessor_expression_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/module_rtc_shim2.cc",
  "src/tint/lang/wgsl/sem/node_rtc_shim3.cc",
  "src/tint/lang/wgsl/sem/statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/struct_rtc_shim2.cc",
  "src/tint/lang/wgsl/sem/switch_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/type_expression.cc",
  "src/tint/lang/wgsl/sem/value_constructor.cc",
  "src/tint/lang/wgsl/sem/value_conversion.cc",
  "src/tint/lang/wgsl/sem/value_expression.cc",
  "src/tint/lang/wgsl/sem/variable_rtc_shim.cc",
  "src/tint/lang/wgsl/sem/while_statement_rtc_shim.cc",
  "src/tint/lang/wgsl/writer/options_rtc_shim1.cc",
  "src/tint/lang/wgsl/writer/output.cc",
  "src/tint/lang/wgsl/writer/writer.cc",
  "src/tint/lang/wgsl/writer/ast_printer/ast_printer.cc",
  "src/tint/lang/wgsl/writer/ir_to_program/ir_to_program.cc",
  "src/tint/lang/wgsl/writer/raise/ptr_to_ref.cc",
  "src/tint/lang/wgsl/writer/raise/raise.cc",
  "src/tint/lang/wgsl/writer/raise/rename_conflicts.cc",
  "src/tint/lang/wgsl/writer/raise/value_to_let_rtc_shim.cc",
  "src/tint/lang/wgsl/writer/syntax_tree_printer/syntax_tree_printer.cc",
  
  -- CMake target: tint_utils
  "src/tint/utils/bytes/buffer_reader.cc",
  "src/tint/utils/bytes/bytes.cc",
  "src/tint/utils/bytes/reader_rtc_shim1.cc",
  "src/tint/utils/bytes/writer_rtc_shim1.cc",
  "src/tint/utils/debug/debugger.cc",
  "src/tint/utils/containers/containers.cc",
  "src/tint/utils/diagnostic/diagnostic.cc",
  "src/tint/utils/diagnostic/formatter.cc",
  "src/tint/utils/diagnostic/source.cc",
  "src/tint/utils/generator/text_generator.cc",
  "src/tint/utils/ice/ice.cc",
  "src/tint/utils/id/generation_id.cc",
  "src/tint/utils/macros/macros.cc",
  "src/tint/utils/math/math_rtc_shim.cc",
  "src/tint/utils/memory/memory.cc",
  "src/tint/utils/reflection/reflection.cc",
  "src/tint/utils/result/result_rtc_shim.cc",
  "src/tint/utils/rtti/castable.cc",
  "src/tint/utils/rtti/switch_rtc_shim.cc",
  "src/tint/utils/strconv/float_to_string.cc",
  "src/tint/utils/strconv/parse_num.cc",
  "src/tint/utils/symbol/symbol.cc",
  "src/tint/utils/symbol/symbol_table.cc",
  "src/tint/utils/text/base64.cc",
  "src/tint/utils/text/string.cc",
  "src/tint/utils/text/string_stream.cc",
  "src/tint/utils/text/styled_text.cc",
  "src/tint/utils/text/styled_text_printer.cc",
  "src/tint/utils/text/styled_text_printer_ansi.cc",
  "src/tint/utils/text/styled_text_theme.cc",
  "src/tint/utils/text/unicode.cc",
  "src/tint/utils/traits/traits.cc",
}

--
-- Platform specifics
--

if (enable_android) then

  files {
    -- CMake target: dawn_native
    "src/dawn/native/AHBFunctions.cpp",
  }

end

if (enable_apple) then

  defines {
    "TINT_BUILD_IS_MAC=1",
  }

  files {
    -- CMake target: dawn_common
    "src/dawn/common/IOSurfaceUtils.cpp",
    "src/dawn/common/SystemUtils_mac.mm",
  }

end

if (enable_linux) then

  defines {
    "DAWN_USE_X11",
    "TINT_BUILD_IS_LINUX=1",
  }

  files {
    "src/dawn/native/X11Functions.cpp",
  }

end

if (enable_win) then

  defines {
    "DAWN_USE_WINDOWS_UI",
    "TINT_BUILD_IS_WIN=1",
    "ENABLE_PCH=1",
  }

  files {
    -- CMake target: dawn_common
    "src/dawn/common/WindowsUtils.cpp",
  }

end

--
-- Shader language specifics
--

if (enable_glsl) then

  files {
    -- CMake target: tint_lang_glsl_validate
    "src/tint/lang/glsl/validate/validate.cc",

    -- CMake target: tint_lang_glsl_writer
    "src/tint/lang/glsl/writer/output_rtc_shim1.cc",
    "src/tint/lang/glsl/writer/writer_rtc_shim2.cc",
    "src/tint/lang/glsl/writer/ast_printer/ast_printer_rtc_shim1.cc",
    "src/tint/lang/glsl/writer/ast_raise/combine_samplers.cc",
    "src/tint/lang/glsl/writer/ast_raise/pad_structs.cc",
    "src/tint/lang/glsl/writer/ast_raise/texture_1d_to_2d.cc",
    "src/tint/lang/glsl/writer/ast_raise/texture_builtins_from_uniform.cc",
    "src/tint/lang/glsl/writer/common/options_rtc_shim2.cc",
    "src/tint/lang/glsl/writer/common/printer_support_rtc_shim.cc",
    "src/tint/lang/glsl/writer/printer/printer_rtc_shim1.cc",
    "src/tint/lang/glsl/writer/raise/raise_rtc_shim1.cc",
  }
  
end

if (enable_hlsl) then

  defines {
    "ENABLE_HLSL",
    "TINT_BUILD_HLSL_WRITER=1",
  }

  files {
    -- CMake target: tint_lang_hlsl_validate
    "src/tint/lang/hlsl/validate/validate_rtc_shim1.cc",

    -- CMake target: tint_lang_hlsl_writer
    "src/tint/lang/hlsl/writer/output_rtc_shim2.cc",
    "src/tint/lang/hlsl/writer/writer_rtc_shim3.cc",
    "src/tint/lang/hlsl/writer/ast_printer/ast_printer_rtc_shim2.cc",
    "src/tint/lang/hlsl/writer/ast_raise/calculate_array_length.cc",
    "src/tint/lang/hlsl/writer/ast_raise/decompose_memory_access.cc",
    "src/tint/lang/hlsl/writer/ast_raise/localize_struct_array_assignment.cc",
    "src/tint/lang/hlsl/writer/ast_raise/num_workgroups_from_uniform.cc",
    "src/tint/lang/hlsl/writer/ast_raise/pixel_local_rtc_shim.cc",
    "src/tint/lang/hlsl/writer/ast_raise/truncate_interstage_variables.cc",
    "src/tint/lang/hlsl/writer/common/option_helpers_rtc_shim.cc",
    "src/tint/lang/hlsl/writer/common/options_rtc_shim3.cc",
    "src/tint/lang/hlsl/writer/helpers/generate_bindings_rtc_shim.cc",
  }

end

if (enable_msl) then

  defines {
    "TINT_BUILD_MSL_WRITER=1",
  }

  files {
    -- CMake target: tint_lang_msl
    "src/tint/lang/msl/builtin_fn_rtc_shim3.cc",
    "src/tint/lang/msl/intrinsic/data_rtc_shim3.cc",
    "src/tint/lang/msl/ir/builtin_call_rtc_shim2.cc",
    "src/tint/lang/msl/validate/validate_rtc_shim2.cc",

    -- CMake target: tint_lang_msl_writer
    "src/tint/lang/msl/writer/writer_rtc_shim4.cc",
    "src/tint/lang/msl/writer/ast_printer/ast_printer_rtc_shim3.cc",
    "src/tint/lang/msl/writer/ast_raise/module_scope_var_to_entry_point_param.cc",
    "src/tint/lang/msl/writer/ast_raise/packed_vec3.cc",
    "src/tint/lang/msl/writer/ast_raise/pixel_local.cc",
    "src/tint/lang/msl/writer/ast_raise/subgroup_ballot.cc",
    "src/tint/lang/msl/writer/common/option_helpers.cc",
    "src/tint/lang/msl/writer/common/options_rtc_shim4.cc",
    "src/tint/lang/msl/writer/common/printer_support.cc",
    "src/tint/lang/msl/writer/helpers/generate_bindings.cc",
    "src/tint/lang/msl/writer/printer/printer.cc",
    "src/tint/lang/msl/writer/raise/builtin_polyfill_rtc_shim2.cc",
    "src/tint/lang/msl/writer/raise/module_scope_vars.cc",
    "src/tint/lang/msl/writer/raise/raise_rtc_shim2.cc",
    "src/tint/lang/msl/writer/output_rtc_shim3.cc",
    "src/tint/lang/msl/writer/writer_rtc_shim5.cc",
  }

end

if (enable_spirv) then

  defines {
    "DAWN_ENABLE_SPIRV_VALIDATION",
    "TINT_BUILD_SPV_READER=1",
    "TINT_BUILD_SPV_WRITER=1",
  }

  includedirs {
    _3RDPARTY_DIR .. "/SPIRV-Headers/include",
    _3RDPARTY_DIR .. "/SPIRV-Tools/include",
    _3RDPARTY_DIR .. "/SPIRV-Tools/out/gen",
    _3RDPARTY_DIR .. "/SPIRV-Tools",
  }

  files {
    -- CMake target: tint_lang_spirv
    "src/tint/lang/spirv/builtin_fn_rtc_shim4.cc",
    "src/tint/lang/spirv/intrinsic/data_rtc_shim4.cc",
    "src/tint/lang/spirv/ir/builtin_call_rtc_shim3.cc",
    "src/tint/lang/spirv/ir/literal_operand.cc",
    "src/tint/lang/spirv/reader/reader_rtc_shim2.cc",
    "src/tint/lang/spirv/reader/ast_lower/atomics.cc",
    "src/tint/lang/spirv/reader/ast_lower/decompose_strided_array.cc",
    "src/tint/lang/spirv/reader/ast_lower/decompose_strided_matrix.cc",
    "src/tint/lang/spirv/reader/ast_lower/fold_trivial_lets.cc",
    "src/tint/lang/spirv/reader/ast_lower/pass_workgroup_id_as_argument.cc",
    "src/tint/lang/spirv/reader/ast_parser/ast_parser.cc",
    "src/tint/lang/spirv/reader/ast_parser/construct_rtc_shim.cc",
    "src/tint/lang/spirv/reader/ast_parser/entry_point_info.cc",
    "src/tint/lang/spirv/reader/ast_parser/enum_converter.cc",
    "src/tint/lang/spirv/reader/ast_parser/function_rtc_shim3.cc",
    "src/tint/lang/spirv/reader/ast_parser/namer.cc",
    "src/tint/lang/spirv/reader/ast_parser/parse.cc",
    "src/tint/lang/spirv/reader/ast_parser/type_rtc_shim2.cc",
    "src/tint/lang/spirv/reader/ast_parser/usage.cc",
    "src/tint/lang/spirv/reader/common/common_rtc_shim2.cc",
    "src/tint/lang/spirv/reader/lower/lower_rtc_shim.cc",
    "src/tint/lang/spirv/reader/lower/shader_io_rtc_shim1.cc",
    "src/tint/lang/spirv/reader/lower/vector_element_pointer.cc",
    "src/tint/lang/spirv/reader/parser/parser_rtc_shim.cc",
    "src/tint/lang/spirv/type/sampled_image.cc",
    "src/tint/lang/spirv/validate/validate_rtc_shim3.cc",
    "src/tint/lang/spirv/writer/output_rtc_shim4.cc",
    "src/tint/lang/spirv/writer/writer_rtc_shim6.cc",
    "src/tint/lang/spirv/writer/ast_printer/ast_printer_rtc_shim4.cc",
    "src/tint/lang/spirv/writer/ast_printer/builder_rtc_shim2.cc",
    "src/tint/lang/spirv/writer/common/binary_writer.cc",
    "src/tint/lang/spirv/writer/common/function_rtc_shim4.cc",
    "src/tint/lang/spirv/writer/common/instruction_rtc_shim.cc",
    "src/tint/lang/spirv/writer/common/module_rtc_shim3.cc",
    "src/tint/lang/spirv/writer/common/operand.cc",
    "src/tint/lang/spirv/writer/common/option_helper.cc",
    "src/tint/lang/spirv/writer/printer/printer_rtc_shim2.cc",
    "src/tint/lang/spirv/writer/raise/builtin_polyfill_rtc_shim3.cc",
    "src/tint/lang/spirv/writer/raise/expand_implicit_splats.cc",
    "src/tint/lang/spirv/writer/raise/handle_matrix_arithmetic.cc",
    "src/tint/lang/spirv/writer/raise/merge_return.cc",
    "src/tint/lang/spirv/writer/raise/pass_matrix_by_pointer.cc",
    "src/tint/lang/spirv/writer/raise/raise_rtc_shim3.cc",
    "src/tint/lang/spirv/writer/raise/shader_io_rtc_shim2.cc",
    "src/tint/lang/spirv/writer/raise/var_for_dynamic_index.cc",
    "src/tint/lang/spirv/writer/ast_raise/for_loop_to_loop.cc",
    "src/tint/lang/spirv/writer/ast_raise/merge_return_rtc_shim.cc",
    "src/tint/lang/spirv/writer/ast_raise/var_for_dynamic_index_rtc_shim.cc",
    "src/tint/lang/spirv/writer/ast_raise/vectorize_matrix_conversions.cc",
    "src/tint/lang/spirv/writer/ast_raise/while_to_loop.cc",
  }

end


--
-- Native GPU API specifics
--

if (enable_d3d12) then -- or d3d11

  includedirs {
    _3RDPARTY_DIR .. "/DirectXShaderCompiler/include/dxc",
    _3RDPARTY_DIR .. "/DirectXShaderCompiler/include",
  }

  files {
    "src/dawn/native/d3d/BackendD3D.cpp",
    "src/dawn/native/d3d/BlobD3D.cpp",
    "src/dawn/native/d3d/D3DError.cpp",
    "src/dawn/native/d3d/DeviceD3D.cpp",
    "src/dawn/native/d3d/KeyedMutex.cpp",
    "src/dawn/native/d3d/PhysicalDeviceD3D.cpp",
    "src/dawn/native/d3d/PlatformFunctions.cpp",
    "src/dawn/native/d3d/QueueD3D.cpp",
    "src/dawn/native/d3d/ShaderUtils.cpp",
    "src/dawn/native/d3d/SharedFenceD3D.cpp",
    "src/dawn/native/d3d/SharedTextureMemoryD3D.cpp",
    "src/dawn/native/d3d/SwapChainD3D.cpp",
    "src/dawn/native/d3d/TextureD3D.cpp",
    "src/dawn/native/d3d/UtilsD3D.cpp",

    "src/dawn/native/d3d/D3DBackend.cpp",
  }

end

if (enable_d3d12) then

  defines {
    "DAWN_ENABLE_BACKEND_D3D12",
    "D3D12_RESOURCE_STATE_ALL_SHADER_RESOURCE=((D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE)|(D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE))",
  }

  files {
    "src/dawn/native/d3d12/BackendD3D12.cpp",
    "src/dawn/native/d3d12/BindGroupD3D12.cpp",
    "src/dawn/native/d3d12/BindGroupLayoutD3D12.cpp",
    "src/dawn/native/d3d12/BufferD3D12.cpp",
    "src/dawn/native/d3d12/CPUDescriptorHeapAllocationD3D12.cpp",
    "src/dawn/native/d3d12/CommandBufferD3D12.cpp",
    "src/dawn/native/d3d12/CommandRecordingContext.cpp",
    "src/dawn/native/d3d12/ComputePipelineD3D12.cpp",
    "src/dawn/native/d3d12/D3D12Info.cpp",
    "src/dawn/native/d3d12/DeviceD3D12.cpp",
    "src/dawn/native/d3d12/GPUDescriptorHeapAllocationD3D12.cpp",
    "src/dawn/native/d3d12/HeapAllocatorD3D12.cpp",
    "src/dawn/native/d3d12/HeapD3D12.cpp",
    "src/dawn/native/d3d12/PageableD3D12.cpp",
    "src/dawn/native/d3d12/PhysicalDeviceD3D12.cpp",
    "src/dawn/native/d3d12/PipelineLayoutD3D12.cpp",
    "src/dawn/native/d3d12/PlatformFunctionsD3D12.cpp",
    "src/dawn/native/d3d12/QuerySetD3D12.cpp",
    "src/dawn/native/d3d12/QueueD3D12.cpp",
    "src/dawn/native/d3d12/RenderPassBuilderD3D12.cpp",
    "src/dawn/native/d3d12/RenderPipelineD3D12.cpp",
    "src/dawn/native/d3d12/ResidencyManagerD3D12.cpp",
    "src/dawn/native/d3d12/ResourceAllocatorManagerD3D12.cpp",
    "src/dawn/native/d3d12/ResourceHeapAllocationD3D12.cpp",
    "src/dawn/native/d3d12/SamplerD3D12.cpp",
    "src/dawn/native/d3d12/SamplerHeapCacheD3D12.cpp",
    "src/dawn/native/d3d12/ShaderModuleD3D12.cpp",
    "src/dawn/native/d3d12/ShaderVisibleDescriptorAllocatorD3D12.cpp",
    "src/dawn/native/d3d12/StagingDescriptorAllocatorD3D12.cpp",
    "src/dawn/native/d3d12/SharedBufferMemoryD3D12.cpp",
    "src/dawn/native/d3d12/SharedFenceD3D12.cpp",
    "src/dawn/native/d3d12/SharedTextureMemoryD3D12.cpp",
    "src/dawn/native/d3d12/StreamImplD3D12.cpp",
    "src/dawn/native/d3d12/SwapChainD3D12.cpp",
    "src/dawn/native/d3d12/TextureCopySplitter.cpp",
    "src/dawn/native/d3d12/TextureD3D12.cpp",
    "src/dawn/native/d3d12/UtilsD3D12.cpp",

    "src/dawn/native/d3d12/D3D12Backend.cpp",
  }

end

if (enable_metal) then

  defines {
    "DAWN_ENABLE_BACKEND_METAL",
  }

  files {
    "src/dawn/native/Surface_metal.mm",
    "src/dawn/native/metal/BackendMTL.mm",
    "src/dawn/native/metal/BindGroupLayoutMTL.mm",
    "src/dawn/native/metal/BindGroupMTL.mm",
    "src/dawn/native/metal/BufferMTL.mm",
    "src/dawn/native/metal/CommandBufferMTL.mm",
    "src/dawn/native/metal/CommandRecordingContext.mm",
    "src/dawn/native/metal/ComputePipelineMTL.mm",
    "src/dawn/native/metal/DeviceMTL.mm",
    "src/dawn/native/metal/PhysicalDeviceMTL.mm",
    "src/dawn/native/metal/PipelineLayoutMTL.mm",
    "src/dawn/native/metal/QueueMTL.mm",
    "src/dawn/native/metal/QuerySetMTL.mm",
    "src/dawn/native/metal/RenderPipelineMTL.mm",
    "src/dawn/native/metal/SamplerMTL.mm",
    "src/dawn/native/metal/ShaderModuleMTL.mm",
    "src/dawn/native/metal/SharedFenceMTL.mm",
    "src/dawn/native/metal/SharedTextureMemoryMTL.mm",
    "src/dawn/native/metal/SwapChainMTL.mm",
    "src/dawn/native/metal/TextureMTL.mm",
    "src/dawn/native/metal/UtilsMetal.mm",

    "src/dawn/native/metal/MetalBackend.mm",
  }

end

if (enable_vulkan) then

  defines {
    "DAWN_ENABLE_BACKEND_VULKAN",
  }

  includedirs {
    _3RDPARTY_DIR .. "/Vulkan-Headers/include",
    _3RDPARTY_DIR .. "/Vulkan-Utility-Libraries/include",
  }

  files {
    "src/dawn/native/SpirvValidation.cpp",
    "src/dawn/native/vulkan/BackendVk.cpp",
    "src/dawn/native/vulkan/BindGroupLayoutVk.cpp",
    "src/dawn/native/vulkan/BindGroupVk.cpp",
    "src/dawn/native/vulkan/BufferVk.cpp",
    "src/dawn/native/vulkan/CommandBufferVk.cpp",
    "src/dawn/native/vulkan/ComputePipelineVk.cpp",
    "src/dawn/native/vulkan/DescriptorSetAllocator.cpp",
    "src/dawn/native/vulkan/DeviceVk.cpp",
    "src/dawn/native/vulkan/FencedDeleter.cpp",
    "src/dawn/native/vulkan/PhysicalDeviceVk.cpp",
    "src/dawn/native/vulkan/PipelineCacheVk.cpp",
    "src/dawn/native/vulkan/PipelineLayoutVk.cpp",
    "src/dawn/native/vulkan/QuerySetVk.cpp",
    "src/dawn/native/vulkan/QueueVk.cpp",
    "src/dawn/native/vulkan/RenderPassCache.cpp",
    "src/dawn/native/vulkan/RenderPipelineVk.cpp",
    "src/dawn/native/vulkan/ResourceHeapVk.cpp",
    "src/dawn/native/vulkan/ResourceMemoryAllocatorVk.cpp",
    "src/dawn/native/vulkan/SamplerVk.cpp",
    "src/dawn/native/vulkan/ShaderModuleVk.cpp",
    "src/dawn/native/vulkan/SharedFenceVk.cpp",
    "src/dawn/native/vulkan/SharedTextureMemoryVk.cpp",
    "src/dawn/native/vulkan/StreamImplVk.cpp",
    "src/dawn/native/vulkan/SwapChainVk.cpp",
    "src/dawn/native/vulkan/TextureVk.cpp",
    "src/dawn/native/vulkan/UtilsVulkan.cpp",
    "src/dawn/native/vulkan/VulkanError.cpp",
    "src/dawn/native/vulkan/VulkanExtensions.cpp",
    "src/dawn/native/vulkan/VulkanFunctions.cpp",
    "src/dawn/native/vulkan/VulkanInfo.cpp",
    "src/dawn/native/vulkan/external_memory/MemoryService.cpp",
    "src/dawn/native/vulkan/external_memory/MemoryServiceImplementation.cpp",
    "src/dawn/native/vulkan/external_semaphore/SemaphoreService.cpp",
    "src/dawn/native/vulkan/external_semaphore/SemaphoreServiceImplementation.cpp",

    "src/dawn/native/vulkan/VulkanBackend.cpp",
  }

  if (_PLATFORM_ANDROID) then

    files {
      "src/dawn/native/vulkan/external_memory/MemoryServiceImplementationAHardwareBuffer.cpp",
      "src/dawn/native/vulkan/external_semaphore/SemaphoreServiceImplementationFD.cpp",
    }

  end

  if (_PLATFORM_LINUX) then

    files {
      "src/dawn/native/vulkan/external_memory/MemoryServiceImplementationDmaBuf.cpp",
      "src/dawn/native/vulkan/external_memory/MemoryServiceImplementationOpaqueFD.cpp",
      "src/dawn/native/vulkan/external_semaphore/SemaphoreServiceImplementationFD.cpp",
    }
  end

end

if (enable_null) then

  defines {
    "DAWN_ENABLE_BACKEND_NULL",
  }

  files {
    "src/dawn/native/null/DeviceNull.cpp",
    "src/dawn/native/null/NullBackend.cpp",
    }
end

if (_PLATFORM_WINDOWS) then

  -- Use the same build options for Test as for Release to overcome D8040
  -- error in Test builds.

  configuration { "Test" }

  buildoptions {
    "/GL", -- Enable whole program optimizations
    "/Gw", -- Optimize Global Data
    -- "/Ob3" is already on for Test builds
    "/wd4701", -- Silences potentially uninitialized local variable warning which causes errors during LTCG
    "/wd4702", -- Silences an unreachable code warning which causes errors during LTCG
    "/wd4706", -- Silences assignment within conditional expression warning which causes errors during LTCG
    "/wd4740", -- Silences flow in or out of inline asm code suppresses global optimization errors during LTCG
  }

end
