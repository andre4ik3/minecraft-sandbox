# Minecraft Sandbox

Scripts and tools to run Minecraft in an isolated sandbox. Currently only
supports MultiMC and its forks on macOS. Each instance will run in its own
sandbox, and will only have write access to its own `.minecraft` folder (not
the folders of other instances), and limited read-only access to Java and the
game assets.

## macOS

1. Clone the repo
2. Open launcher settings
3. Go to "Custom Commands"
4. Set "Wrapper command" to the path of the `darwin/wrapper.sh` file

![Launcher custom commands settings](./assets/launcher-settings.webp)

5. (Optional) By default, multiplayer is allowed and microphone access is
   disallowed. Change these settings on a per-instance basis by setting the
   `SANDBOX_ALLOW_MICROPHONE` and `SANDBOX_ALLOW_MULTIPLAYER` environment
   variables in the instance settings

![Instance environment variables](./assets/instance-settings.webp)

## Linux

Running the launcher in a Flatpak already provides sandboxing from the rest of
the system. However, each instance can still access and modify the data of
other instances. It should be possible to sandbox each instance individually by
using [Bubblewrap](https://github.com/containers/bubblewrap), however this is
not yet done.
