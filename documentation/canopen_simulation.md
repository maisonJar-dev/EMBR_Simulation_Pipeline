# CANopen Simulation

## Scope

The `canopen-sim` service is the development environment for the Maxon motor
model and future CANopen/ESCON simulation. The current implementation provides:

- A reproducible ROS 2 Humble container
- ROS 2 CANopen and SocketCAN tooling
- A host-mounted ROS workspace
- A Maxon motor description with movable shaft joint
- RViz visualization and joint-state controls
- Empty scaffolds for the simulated ESCON and command adapter

The current RViz launch does not emulate an ESCON controller, transmit CANopen
frames, or simulate motor physics.

## Files

```text
compose.yaml
docker/
├── CANopen-Spec-Dockerfile
└── canopen-entrypoint.sh
embr_sim/ros2_ws/src/
├── embr_description/
│   ├── launch/view_maxon_motor.launch.py
│   ├── meshes/maxon_motor/meshes/*.stl
│   ├── rviz/maxon_motor.rviz
│   └── urdf/maxon_motor/urdf/maxon_motor.urdf.xacro
├── embr_canopen_sim/
│   ├── config/motor_nodes.yaml
│   ├── launch/canopen_sim.launch.py
│   └── src/
│       ├── motor_command_adapter.cpp
│       └── simulate_escon.cpp
└── embr_gazebo/
    ├── config/bridge.yaml
    └── worlds/
```

## Quick start: RViz model

From the repository root:

```bash
docker compose build canopen-sim &&
docker compose up -d --force-recreate canopen-sim
docker compose exec canopen-sim bash
```

Inside the container:

```bash
cd /workspace/canopen_ws
source /opt/ros/humble/setup.bash
colcon build --symlink-install --packages-select embr_description
source install/setup.bash
ros2 launch embr_description view_maxon_motor.launch.py
```

RViz displays the body, shaft, and electrical tabs. The
`joint_state_publisher_gui` window controls the continuous `shaft` joint.

## Runtime interfaces

The service uses:

| Interface | Purpose |
| --- | --- |
| `/workspace/canopen_ws` | Container workspace bind-mounted from `embr_sim/ros2_ws` |
| `/tmp/.X11-unix` | X11 socket used by RViz and Gazebo |
| `XAUTHORITY` | Host X11 authorization file |
| `CAN_INTERFACE` | SocketCAN interface name; defaults to `vcan0` |
| `ROS_DOMAIN_ID` | ROS 2 discovery domain; defaults to `0` |
| Host network | ROS 2 discovery and access to host network interfaces |
| `NET_ADMIN` | Allows CAN network-interface configuration where supported |

## Virtual CAN interface

The intended development interface is `vcan0`. Check it inside the container:

```bash
ip -brief link show type can
```

If no interface is present, the host must provide Virtual CAN kernel support.
Depending on the host Docker and kernel configuration, create and activate the
interface on the host or from a process with `NET_ADMIN`:

```bash
sudo modprobe vcan
sudo ip link add dev vcan0 type vcan
sudo ip link set up vcan0
```

Verify traffic with SocketCAN utilities:

```bash
candump vcan0
```

In a second terminal:

```bash
cansend vcan0 123#DEADBEEF
```

These commands test the virtual bus only; they do not start the ROS 2 CANopen
stack.

## Generated directories

Running `colcon build` creates:

- `build/`: CMake and compiler intermediates
- `install/`: installed packages and ROS environment hooks
- `log/`: build logs

They appear in `embr_sim/ros2_ws` because it is a bind mount. This is expected.
They are generated artifacts and should not be committed.

## Rebuild rules

Rebuild the Docker image after changes to:

- `docker/CANopen-Spec-Dockerfile`
- System or ROS package dependencies
- Build arguments or the base image

Only rebuild the ROS workspace after changes to:

- CMake or package manifests
- URDF/Xacro, launch, RViz, or YAML files
- C++ source files

## Current limitations and next integration steps

Before the motor can be controlled through simulated CANopen:

1. Define the motor/drive object dictionary and bus configuration.
2. Implement or configure the simulated ESCON node.
3. Define command and feedback interfaces.
4. Populate `motor_nodes.yaml`.
5. Populate `canopen_sim.launch.py`.
6. Add the C++ targets and dependencies to `embr_canopen_sim/CMakeLists.txt`.
7. Connect joint feedback to the `shaft` joint.
8. Add Gazebo collision geometry and verified mass/inertia values if physical
   simulation is required.

RViz should remain the first model-validation step. It confirms mesh paths,
joint topology, TF publication, and joint movement without adding physics or
CANopen complexity.

## Troubleshooting

### RViz opens but the motor is not visible

- Confirm the fixed frame is `root`.
- Check the `Maxon Motor` display status.
- Use the close-range Orbit view or select the model and press `F`.
- Confirm `/robot_description` and `/tf` are being published.

### `ament_cmake` cannot be found

The new image was probably not built or ROS was not sourced:

```bash
source /opt/ros/humble/setup.bash
```

Rebuild the image and use `&&` before `docker compose up` so an old cached image
is not started after a failed build.

### Package manifest XML error

The XML declaration must begin at the first byte of `package.xml`:

```xml
<?xml version="1.0"?>
```

No spaces or blank lines may precede it.

### Workspace cannot be edited on the host

Confirm the Compose service uses the host UID/GID and repair artifacts left by
older root-running containers:

```bash
sudo chown -R "$(id -u):$(id -g)" embr_sim/ros2_ws
```
