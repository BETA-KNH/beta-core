## What & Why

<!-- What changed and why. Link related issues if any. -->

## Type of change

- [ ] New package / node
- [ ] Bug fix
- [ ] Refactor
- [ ] CI / tooling
- [ ] Documentation / ADR

## Testing

<!-- Which packages were tested and how. -->

```bash
make test-pkg PKG=<package_name>
# or
make test
```

- [ ] `colcon test` passes locally
- [ ] `make lint` passes (or pre-commit clean)
- [ ] Tested on hardware / simulation (describe below if yes)

## Checklist

- [ ] Every new node is a `rclcpp_lifecycle::LifecycleNode`
- [ ] QoS profiles match the data type (sensor → `SensorDataQoS`, commands → `SystemDefaultsQoS`)
- [ ] New architecture decisions recorded in `docs/decisions/`
