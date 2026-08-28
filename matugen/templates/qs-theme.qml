pragma Singleton

import QtQuick

QtObject {
    readonly property real scale: 1.2

    readonly property color background: "{{ colors.surface.default.hex }}"
    readonly property color surface: "{{ colors.surface_container.default.hex }}"
    readonly property color surfaceVariant: "{{ colors.surface_variant.default.hex }}"

    readonly property color text: "{{ colors.on_surface.default.hex }}"
    readonly property color textMuted: "{{ colors.on_surface_variant.default.hex }}"

    readonly property color accent: "{{ colors.primary.default.hex }}"
    readonly property color accentText: "{{ colors.on_primary.default.hex }}"

    readonly property color surfaceHover: "{{ colors.surface_container_high.default.hex }}"
    readonly property color accentHover: "{{ colors.primary_fixed_dim.default.hex }}"

    readonly property color outline: "{{ colors.outline.default.hex }}"
}
