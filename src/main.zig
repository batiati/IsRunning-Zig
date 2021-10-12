const std = @import("std");
const win32 = @import("./win32.zig");

const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator(.{});
const StringHashMap = std.StringHashMap(void);
const Allocator = std.mem.Allocator;

pub fn main() u8 {
    const FOUND = 0;
    const NOT_FOUND = 1;

    var gpa = GeneralPurposeAllocator{};
    defer _ = gpa.deinit();
    var allocator = &gpa.allocator;

    var args = getArgs(allocator) orelse return NOT_FOUND;
    defer deinitArgs(&args);

    var processes = getProcesses(allocator) orelse return NOT_FOUND;
    defer allocator.free(processes);

    for (processes) |process_id| {
        var name = getProcessName(allocator, process_id) orelse continue;
        defer allocator.free(name);

        if (args.contains(toUpper(name))) {
            return FOUND;
        }
    }

    return NOT_FOUND;
}

fn getArgs(allocator: *Allocator) ?StringHashMap {
    var iterator = std.process.ArgIterator.init();
    defer iterator.deinit();

    if (!iterator.skip()) return null;

    var args = StringHashMap.init(allocator);

    while (iterator.next(allocator)) |arg| {
        var key = arg catch unreachable;
        var entry = args.getOrPut(toUpper(key)) catch unreachable;
        if (entry.found_existing) {
            allocator.free(key);
        }
    }

    if (args.count() == 0) {
        args.deinit();
        return null;
    } else {
        return args;
    }
}

fn deinitArgs(args: *StringHashMap) void {
    var allocator = args.allocator;
    var keys = args.keyIterator();
    while (keys.next()) |key| {
        allocator.free(key.*);
    }
    args.deinit();
}

fn toUpper(str: []u8) []u8 {
    for (str) |*char| {
        char.* = std.ascii.toUpper(char.*);
    }
    return str;
}

fn getProcesses(allocator: *Allocator) ?[]win32.DWORD {

    // It's likely to have few processes inside a container
    // Starting with a small buffer and grow as needed
    var max_process: usize = 16;
    var processes_buffer = allocator.alloc(win32.DWORD, max_process) catch unreachable;
    errdefer allocator.free(processes_buffer);
    var len: win32.DWORD = undefined;

    while (true) {
        var ret = win32.EnumProcesses(processes_buffer.ptr, @intCast(win32.DWORD, processes_buffer.len * @sizeOf(win32.DWORD)), &len);
        len /= @sizeOf(win32.DWORD);

        if (ret == win32.FALSE or len == 0) {
            return null;
        } else if (len == max_process) {
            // Double the buffer size
            max_process *= 2;
            processes_buffer = allocator.realloc(processes_buffer, max_process) catch unreachable;
            continue;
        } else {
            return allocator.shrink(processes_buffer, len);
        }
    }
}

fn getProcessName(allocator: *Allocator, process_id: win32.DWORD) ?[]u8 {
    var process_handle = win32.OpenProcess(win32.DESIRED_ACCESS, win32.FALSE, process_id) orelse return null;

    var module: [1]win32.HMODULE = undefined;
    var len: win32.DWORD = undefined;
    var ret = win32.EnumProcessModules(process_handle, &module, @intCast(win32.DWORD, @sizeOf(win32.HMODULE)), &len);
    len /= @sizeOf(win32.HMODULE);

    if (ret == win32.FALSE or len == 0) {
        return null;
    } else {

        // Starting with a small buffer and grow as needed
        var max_process_name: usize = 32;
        var name_buffer = allocator.allocSentinel(win32.CHAR, max_process_name, 0) catch unreachable;
        errdefer allocator.free(name_buffer);

        while (true) {
            len = win32.GetModuleBaseName(process_handle, module[0], name_buffer.ptr, @intCast(win32.DWORD, max_process_name));

            if (len >= max_process_name) {
                // Double the buffer size
                max_process_name *= 2;
                name_buffer = std.meta.assumeSentinel(allocator.realloc(name_buffer, max_process_name) catch unreachable, 0);
            } else {
                return allocator.shrink(name_buffer, len);
            }
        }
    }
}
