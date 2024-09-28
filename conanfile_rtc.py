from conans import ConanFile

class DawnConan(ConanFile):
    name = "dawn"
    version = "0.0.1"
    url = "https://github.com/Esri/dawn/blob/runtimecore"
    license = "https://github.com/Esri/dawn/blob/runtimecore/LICENSE"
    description = "Dawn is an open-source and cross-platform implementation of the WebGPU standard."

    # RTC specific triple
    settings = "platform_architecture_target"

    def package(self):
        base = self.source_folder
        relative = "3rdparty/dawn"

        # headers
        # Expose only webgpu.h to RTC, at present
        self.copy("webgpu.h", src=base + "/include/webgpu", dst=relative + "/include/webgpu")
        self.copy("webgpu.h", src=base + "/out/gen/include/dawn", dst=relative + "/out/gen/include/dawn")

        # libraries
        output = "output/" + str(self.settings.platform_architecture_target) + "/staticlib"
        self.copy("*" + self.name + "*", src=base + "/../../" + output, dst=output)
