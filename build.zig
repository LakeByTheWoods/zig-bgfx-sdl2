const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("game", "src/main.zig");

    const git_sub_cmd = [_][]const u8{ "git", "submodule", "update", "--init", "--recursive" };
    const fetch_subs = b.addSystemCommand(&git_sub_cmd);

    exe.addIncludeDir("src");

    exe.linkLibC();
    exe.linkSystemLibrary("c++");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("GL");

    comptime const cxx_options = [_][]const u8{
        "-fno-strict-aliasing",
        "-fno-exceptions",
        "-fno-rtti",
        "-ffast-math",
    };
    // Define to enable some debug prints in BGFX
    //exe.defineCMacro("BGFX_CONFIG_DEBUG=1");

    // bx
    comptime const bx = "submodules/bx/";
    exe.addIncludeDir(bx ++ "include/");
    exe.addIncludeDir(bx ++ "3rdparty/");
    exe.addCSourceFile(bx ++ "src/amalgamated.cpp", &cxx_options);

    // bimg
    comptime const bimg = "submodules/bimg/";
    exe.addIncludeDir(bimg ++ "include/");
    exe.addIncludeDir(bimg ++ "3rdparty/");
    exe.addIncludeDir(bimg ++ "3rdparty/astc-codec/");
    exe.addIncludeDir(bimg ++ "3rdparty/astc-codec/include/");
    exe.addCSourceFile(bimg ++ "src/image.cpp", &cxx_options);
    exe.addCSourceFile(bimg ++ "src/image_gnf.cpp", &cxx_options);
    // FIXME: Glob?
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/astc_file.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/codec.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/endpoint_codec.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/footprint.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/integer_sequence_codec.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/intermediate_astc_block.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/logical_astc_block.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/partition.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/physical_astc_block.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/quantization.cc", &cxx_options);
    exe.addCSourceFile(bimg ++ "3rdparty/astc-codec/src/decoder/weight_infill.cc", &cxx_options);

    // bgfx
    comptime const bgfx = "submodules/bgfx/";
    exe.addIncludeDir(bgfx ++ "include/");
    exe.addIncludeDir(bgfx ++ "3rdparty/");
    exe.addIncludeDir(bgfx ++ "3rdparty/dxsdk/include/");
    exe.addIncludeDir(bgfx ++ "3rdparty/khronos/");
    exe.addIncludeDir(bgfx ++ "src/");
    exe.addCSourceFile(bgfx ++ "src/amalgamated.cpp", &cxx_options);

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const fetch_step = b.step("fetch", "Fetch submodules");
    fetch_step.dependOn(&fetch_subs.step);
}
