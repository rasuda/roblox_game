# A-Chassis reference car

Unmodified upstream A-Chassis 1.7.2 car (not the motorcycle / M package).

- Upstream: https://github.com/lisphm/A-Chassis
- Release: https://github.com/lisphm/A-Chassis/releases/tag/v1.7.2-stable
- Asset: A-Chassis.1.7.2.rbxm
- SHA-256: df344662f30c83f42a83aad8ff8168db8a58932fcd7ddc79bff8f411b6743c67
- License: Mozilla Public License 2.0, included in LICENSE.
- Source is embedded in the editable RBXM; upstream source is linked above.

Integration code: src/server/AChassisDemo.server.lua. It clones the model from
ServerStorage, positions it beside the Nivus and adds a proximity prompt. It does
not replace the native chassis controller or modify tuning. Native Tune.Mobile
and Tune.AutoStart are enabled in the upstream package. Touch mode defaults to
Tap (separate accelerator, brake, left and right buttons).

Validation: asset digest, deserialization, embedded Luau compilation and Rojo
build. Real driving/physics, audio permissions and iPhone UI require an in-game
playtest. Do not treat successful publishing as a physics playtest.
