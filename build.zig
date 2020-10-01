const std = @import("std");

const Builder = std.build.Builder;
const builtin = std.builtin;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("game", "src/main.zig");

    const git_sub_cmd = [_][]const u8{ "git", "submodule", "update", "--init", "--recursive" };
    const fetch_subs = b.addSystemCommand(&git_sub_cmd);

    exe.addIncludeDir("src");

    exe.linkLibC();
    exe.linkSystemLibrary("c++");
    exe.linkSystemLibrary("SDL2");

    if (builtin.os.tag == .linux) {
        exe.linkSystemLibrary("GL");
        exe.linkSystemLibrary("X11");
    }

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
    if (builtin.os.tag == .macosx) {
        exe.addIncludeDir(bx ++ "include/compat/osx/");
        exe.addFrameworkDir("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks");
        exe.addSystemIncludeDir("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include");
        exe.addSystemIncludeDir("/usr/local/Cellar/llvm/10.0.1/lib/clang/10.0.1/include");
        exe.linkFramework("Cocoa");
        exe.linkFramework("CoreFoundation");
        exe.linkFramework("OpenGL");
        exe.linkFramework("Metal");
    }

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
    if (builtin.os.tag == .macosx) {
        exe.addCSourceFile(bgfx ++ "src/amalgamated.mm", &cxx_options);
    } else {
        exe.addCSourceFile(bgfx ++ "src/amalgamated.cpp", &cxx_options);
    }

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
