**English** | [Español](vmware.es.md)

# VMware

Requirements and settings to run the setup in a VMware VM.

## VM settings

With the VM powered off, in VM -> Settings:

1. Hardware -> Display: check "Accelerate 3D graphics" and assign 2 GB or
   more of "Graphics memory".
2. When logging into Parrot, pick the `bspwm` session (X11). bspwm does not
   run on Wayland.

`bootstrap.sh` installs `open-vm-tools-desktop` (shared clipboard, automatic
resolution and shared folders) when it detects VMware.

## Check graphics acceleration

```bash
glxinfo -B | grep -E "renderer|Accelerated"
```

| Result | Meaning |
|---|---|
| Renderer `SVGA3D` | The virtual GPU works |
| Renderer `llvmpipe` | Software rendering: enable "Accelerate 3D graphics" |

The `Accelerated: no` line shows up even when the GPU works: it is a false
positive from the `vmwgfx` driver. The reliable signal is the renderer.

picom uses the `glx` backend (compositing on the GPU). With `xrender` it
composited on the CPU and switching workspaces was slow.

## Shared folder with the host

To move files between Windows and Linux in both directions.

1. On Windows, create a dedicated folder, for example `C:\VMShare`. Do not
   share the whole disk: if the VM is compromised, it only reaches that
   folder.
2. In VMware, with the VM running: VM -> Settings -> Options -> Shared
   Folders. Check "Always enabled", click "Add...", choose the folder and name
   it `VMShare` (with that capitalization). Leave "Read-only" unchecked.
3. Check that the VM sees it (it must answer `VMShare`):

    ```bash
    vmware-hgfsclient
    ```

4. Mount it. From `~/dotfiles`, requires sudo:

    ```bash
    sudo ./system/setup.sh
    ```

    Step `[8/9]` mounts it at `/mnt/vmshare`, creates the `~/VMShare`
    shortcut and adds it to `/etc/fstab`. Only your user can read it, and if
    you disable it in VMware the system still boots.

Everything you put in `C:\VMShare` shows up in `~/VMShare`, and the other way
around.

### Move a sensitive file without leaving copies

For keys or backups: copy, check that it arrived intact and delete the
original. Example with `file.asc`:

1. Copy:

    ```bash
    cp ~/file.asc ~/VMShare/
    ```

2. Compare the hashes: both lines must show the same hash:

    ```bash
    sha256sum ~/file.asc ~/VMShare/file.asc
    ```

3. Delete the original:

    ```bash
    rm ~/file.asc
    ```

4. On Windows, move the file from `C:\VMShare` to its destination and empty
   the recycle bin. The shared folder is a hand-off point, not storage.
