# PID 0x002F removal build

GitHub Actions builds Win32 and x64 DLLs in both Release and Release_Static configurations on windows-2022.
The build uses VS 2022/v143 for all three projects; the original project files remain unchanged.
Dependencies are checked out at the submodule revisions recorded in Git.
Only BaseClasses, muparser and BonDriver_BDA are built. TBS.dll is not required for standard BDA reception.

Enable DeletePID002F=YES in the relevant [TuningSpaceNN] section.
For TSMFMode=TSID/Relative, filtering happens after TSMF processing.
For TSMFMode=OFF, the normal packet filter removes PID 0x002F.
DeleteNullPackets is configured separately in [BonDriver].

Download the matching Win32/x64 artifact from the Actions run page.
Rename BonDriver_BDA.dll to match the existing BonDriver filename, then replace it while the application is closed.
Keep the existing matching INI file.

To build locally with VS 2022 C++ tools, ATL and Windows SDK installed:

```powershell
./scripts/build.ps1 -Platform x64 -Configuration Release
```

Release uses the dynamic Visual C++ runtime and requires the matching x86/x64 Visual C++ Redistributable. Release_Static includes the runtime in the DLL.
