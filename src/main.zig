const std = @import("std");

const assert = std.debug.assert;
const meta = std.meta;
const builtin = std.builtin;

usingnamespace @cImport({
    @cInclude("stdio.h");
    @cInclude("string.h");
    @cInclude("unistd.h");
    @cInclude("time.h");
    @cInclude("errno.h");
    @cInclude("stdintfix.h"); // NB: Required as zig is unable to process some macros

    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_syswm.h");

    @cInclude("GL/gl.h");
    @cInclude("GL/glx.h");
    @cInclude("GL/glext.h");

    @cInclude("bgfx/c99/bgfx.h");
});

fn sdlSetWindow(window: *SDL_Window) !void {
    var wmi: SDL_SysWMinfo = undefined;
    wmi.version.major = SDL_MAJOR_VERSION;
    wmi.version.minor = SDL_MINOR_VERSION;
    wmi.version.patch = SDL_PATCHLEVEL;
    if (SDL_GetWindowWMInfo(window, &wmi) == .SDL_FALSE) {
        return error.SDL_FAILED_INIT;
    }

    var pd = std.mem.zeroes(bgfx_platform_data_t);
    if (builtin.os.tag == .linux) {
        pd.ndt = wmi.info.x11.display;
        pd.nwh = meta.cast(*c_void, wmi.info.x11.window);
    }
    if (builtin.os.tag == .freebsd) {
        pd.ndt = wmi.info.x11.display;
        pd.nwh = meta.cast(*c_void, wmi.info.x11.window);
    }
    if (builtin.os.tag == .macosx) {
        pd.ndt = NULL;
        pd.nwh = wmi.info.cocoa.window;
    }
    if (builtin.os.tag == .windows) {
        pd.ndt = NULL;
        pd.nwh = wmi.info.win.window;
    }
    //if (builtin.os.tag == .steamlink) {
    //    pd.ndt = wmi.info.vivante.display;
    //    pd.nwh = wmi.info.vivante.window;
    //}
    pd.context = NULL;
    pd.backBuffer = NULL;
    pd.backBufferDS = NULL;
    bgfx_set_platform_data(&pd);
}

pub fn main() !void {
    _ = SDL_Init(0);
    defer SDL_Quit();
    const window = SDL_CreateWindow("bgfx", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE).?;
    defer SDL_DestroyWindow(window);
    try sdlSetWindow(window);

    var in = std.mem.zeroes(bgfx_init_t);
    in.type = bgfx_renderer_type.BGFX_RENDERER_TYPE_COUNT; // Automatically choose a renderer.
    in.resolution.width = 800;
    in.resolution.height = 600;
    in.resolution.reset = BGFX_RESET_VSYNC;
    var success = bgfx_init(&in);
    defer bgfx_shutdown();
    assert(success);

    bgfx_set_debug(BGFX_DEBUG_TEXT);

    bgfx_set_view_clear(0, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH, 0x443355FF, 1.0, 0);
    bgfx_set_view_rect(0, 0, 0, 800, 600);

    var frame_number: u64 = 0;
    gameloop: while (true) {
        var event: SDL_Event = undefined;
        var should_exit = false;
        while (SDL_PollEvent(&event) == 1) {
            switch (event.type) {
                SDL_QUIT => should_exit = true,

                SDL_WINDOWEVENT => {
                    const wev = &event.window;
                    switch (wev.event) {
                        SDL_WINDOWEVENT_RESIZED, SDL_WINDOWEVENT_SIZE_CHANGED => {},

                        SDL_WINDOWEVENT_CLOSE => should_exit = true,

                        else => {},
                    }
                },

                else => {},
            }
        }
        if (should_exit) break :gameloop;

        bgfx_set_view_rect(0, 0, 0, 800, 600);
        bgfx_touch(0);
        bgfx_dbg_text_clear(0, false);
        bgfx_dbg_text_printf(0, 1, 0x4f, "Frame#:%d", frame_number);
        frame_number = bgfx_frame(false);
    }
}
