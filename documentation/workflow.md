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
source /opt/ros/humble/setup.bash
```

## Build the workspaces

For normal development:

```bash
cd /workspace/embr_phys_ws
colcon build --symlink-install
source /workspace/embr_phys_ws/install/setup.bash
cd /workspace/embr_sim_ws
colcon build --symlink-install
source /workspace/embr_sim_ws/install/setup.bash
```

To build only the model package:

```bash
cd /workspace/embr_phys_ws
colcon build --symlink-install --packages-select embr_description
source /workspace/embr_phys_ws/install/setup.bash
```

Use `--cmake-clean-cache` after changing package names, CMake configuration, or
build dependencies:

```bash
cd /workspace/embr_phys_ws
colcon build --symlink-install \
  --packages-select embr_description \
  --cmake-clean-cache
source /workspace/embr_phys_ws/install/setup.bash
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
embr_phys/ros2_ws/src   Hardware-neutral descriptions and robot packages
embr_sim/ros2_ws/src    Gazebo and simulated-device packages
```

Because both workspaces are bind-mounted, changes are immediately visible
inside the container. Build and source the physical underlay before the
simulation overlay, then restart the affected launch file.

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
stat -c '%U:%G %n' embr_phys/ros2_ws embr_sim/ros2_ws
```

If files left by an older root-running container have incorrect ownership,
repair them once from the host:

```bash
sudo chown -R "$(id -u):$(id -g)" embr_phys/ros2_ws embr_sim/ros2_ws
```

Do not run the service as root to work around workspace permissions.
