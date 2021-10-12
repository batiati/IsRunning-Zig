const std = @import("std");
const os = std.os.windows;

pub const HANDLE = os.HANDLE;
pub const HMODULE = os.HMODULE;
pub const DWORD = os.DWORD;
pub const LPDWORD = os.LPDWORD;
pub const LPSTR = os.LPSTR;
pub const CHAR = os.CHAR;
pub const BOOL = os.BOOL;
pub const TRUE = os.TRUE;
pub const FALSE = os.FALSE;

pub const EnumProcesses = os.psapi.EnumProcesses;
pub const EnumProcessModules = os.psapi.EnumProcessModules;
pub const GetModuleBaseName = os.psapi.GetModuleBaseNameA;

pub extern "kernel32" fn OpenProcess(
    dwDesiredAccess: DWORD,
    bInheritHandle: BOOL,
    dwProcessId: DWORD,
) callconv(os.WINAPI) ?HANDLE;

pub const PROCESS_ACCESS_RIGHTS = struct {
    pub const TERMINATE: DWORD = 1;
    pub const CREATE_THREAD: DWORD = 2;
    pub const SET_SESSIONID: DWORD = 4;
    pub const VM_OPERATION: DWORD = 8;
    pub const VM_READ: DWORD = 16;
    pub const VM_WRITE: DWORD = 32;
    pub const DUP_HANDLE: DWORD = 64;
    pub const CREATE_PROCESS: DWORD = 128;
    pub const SET_QUOTA: DWORD = 256;
    pub const SET_INFORMATION: DWORD = 512;
    pub const QUERY_INFORMATION: DWORD = 1024;
    pub const SUSPEND_RESUME: DWORD = 2048;
    pub const QUERY_LIMITED_INFORMATION: DWORD = 4096;
    pub const SET_LIMITED_INFORMATION: DWORD = 8192;
    pub const ALL_ACCESS: DWORD = 2097151;
    pub const DELETE: DWORD = 65536;
    pub const READ_CONTROL: DWORD = 131072;
    pub const WRITE_DAC: DWORD = 262144;
    pub const WRITE_OWNER: DWORD = 524288;
    pub const SYNCHRONIZE: DWORD = 1048576;
    pub const STANDARD_RIGHTS_REQUIRED: DWORD = 983040;
};
