# Development Workflow

## One-time environment setup

Copy the example environment file if `.env` does not exist:

```bash
cp .env.example .env
```

Set the container identity to match the host:

```bash
id -u
id -g
```

Store those values as `LOCAL_UID` and `LOCAL_GID` in `.env`. Both default to
`1000`.

## Build the CANopen image

Build after changing the Dockerfile, ROS dependencies, or package manifests:

```bash
docker compose build canopen-sim
```

For complete build diagnostics:

```bash
docker compose --progress plain build canopen-sim
```

Start a newly built image only if the build succeeds:

```bash
docker compose build canopen-sim &&
docker compose up -d --force-recreate canopen-sim
```

Using `&&` is important: if the build fails, Compose will not start an older
cached image.

## Enter the development container

```bash
docker compose exec canopen-sim bash
```

The following commands in this document run inside the container:

```bash
cd /workspace/canopen_ws
source /opt/ros/humble/setup.bash
```

## Build the workspace

For normal development:

```bash
colcon build --symlink-install
source install/setup.bash
```

To build only the model package:

```bash
colcon build --symlink-install --packages-select embr_description
source install/setup.bash
```

Use `--cmake-clean-cache` after changing package names, CMake configuration, or
build dependencies:

```bash
colcon build --symlink-install \
  --packages-select embr_description \
  --cmake-clean-cache
```

## View the Maxon motor

```bash
ros2 launch embr_description view_maxon_motor.launch.py
```

This starts RViz and the joint-state GUI. In RViz:

- Left drag orbits the camera.
- Middle drag pans.
- The scroll wheel zooms.
- `F` focuses the camera on the selected object.
- The separate joint-state window changes the shaft angle.

## Editing loop

Source and mesh files are edited on the host under:

```text
embr_sim/ros2_ws/src
```

Because the workspace is bind-mounted, changes are immediately visible inside
the container. Re-run `colcon build --symlink-install`, source
`install/setup.bash`, and restart the affected launch file.

A Docker image rebuild is not normally required for source, launch, URDF,
mesh, RViz, or YAML edits.

## Stop the service

```bash
docker compose stop canopen-sim
```

Remove the container while retaining the image and host workspace:

```bash
docker compose down
```

## Ownership

Files created in the workspace should match the host UID/GID. Verify with:

```bash
stat -c '%U:%G %n' embr_sim/ros2_ws
```

If files left by an older root-running container have incorrect ownership,
repair them once from the host:

```bash
sudo chown -R "$(id -u):$(id -g)" embr_sim/ros2_ws
```

Do not run the service as root to work around workspace permissions.
