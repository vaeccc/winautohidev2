param(
 [Parameter(Mandatory=$true)][string]$ExePath,
 [Parameter(Mandatory=$true)][string]$ScriptPath
)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class EdgeHideWinRes {
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
 public static extern IntPtr BeginUpdateResource(string path, bool deleteExisting);
 [DllImport("kernel32.dll", SetLastError=true)]
 public static extern bool UpdateResource(IntPtr h, IntPtr type, IntPtr name, ushort lang, byte[] data, uint size);
 [DllImport("kernel32.dll", SetLastError=true)]
 public static extern bool EndUpdateResource(IntPtr h, bool discard);
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
 public static extern IntPtr LoadLibraryEx(string path, IntPtr reserved, uint flags);
 [DllImport("kernel32.dll", SetLastError=true)]
 public static extern IntPtr FindResource(IntPtr module, IntPtr name, IntPtr type);
 [DllImport("kernel32.dll", SetLastError=true)]
 public static extern uint SizeofResource(IntPtr module, IntPtr info);
 [DllImport("kernel32.dll", SetLastError=true)]
 public static extern bool FreeLibrary(IntPtr module);
}
'@
$exe = (Resolve-Path -LiteralPath $ExePath).Path
[byte[]]$bytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $ScriptPath).Path)
if ($bytes.Length -lt 100) { throw 'Missing script content' }
if (!($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191)) {
 [byte[]]$bytes = [byte[]](239,187,191) + $bytes
}
$h = [EdgeHideWinRes]::BeginUpdateResource($exe, $false)
if ($h -eq [IntPtr]::Zero) { throw 'Failed to open executable resources' }
$ok = [EdgeHideWinRes]::UpdateResource($h, [IntPtr]10, [IntPtr]1, [ushort]1033, $bytes, [uint32]$bytes.Length)
if (!$ok) {
 $last = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
 [void][EdgeHideWinRes]::EndUpdateResource($h, $true)
 throw "Script resource update failed: $last"
}
if (![EdgeHideWinRes]::EndUpdateResource($h, $false)) { throw 'Script resource commit failed' }
$m = [EdgeHideWinRes]::LoadLibraryEx($exe, [IntPtr]::Zero, [uint32]2)
if ($m -eq [IntPtr]::Zero) { throw 'Failed to validate executable resource' }
try {
 $info = [EdgeHideWinRes]::FindResource($m, [IntPtr]1, [IntPtr]10)
 if ($info -eq [IntPtr]::Zero) { throw 'Missing RCDATA #1 script resource' }
 $length = [EdgeHideWinRes]::SizeofResource($m, $info)
 if ($length -ne $bytes.Length) { throw "Script resource size mismatch: $length vs $($bytes.Length)" }
 Write-Host "Embedded EdgeHide script resource #1: $length bytes"
} finally {
 [void][EdgeHideWinRes]::FreeLibrary($m)
}
