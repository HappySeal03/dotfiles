pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../../theme"

Rectangle {
    id: root

    Layout.fillWidth: true
    implicitHeight: 250

    color: Theme.surface
    border.width: 1
    border.color: Theme.outline
    radius: 10

    property date currentDate: new Date()

    readonly property var weekdays: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    readonly property int firstDay: firstDayOfMonth(currentDate.getFullYear(), currentDate.getMonth())

    readonly property int days: daysInMonth(currentDate.getFullYear(), currentDate.getMonth())

    readonly property int weeks: Math.ceil((firstDay + days) / 7)

    function changeMonth(delta) {
        let d = new Date(currentDate);
        d.setMonth(d.getMonth() + delta);
        currentDate = d;
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfMonth(year, month) {
        // JS: Sunday = 0, Monday = 1, ...
        // Convert to Monday = 0, Sunday = 6
        return (new Date(year, month, 1).getDay() + 6) % 7;
    }

    function isToday(day) {
        let today = new Date();

        return currentDate.getFullYear() === today.getFullYear() && currentDate.getMonth() === today.getMonth() && day === today.getDate();
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 8
        }

        spacing: 8

        // Month navigation
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8

            Text {
                text: Qt.formatDate(root.currentDate, "MMMM yyyy")
                color: Theme.text
                font.pixelSize: 16
                font.bold: true

                Layout.fillWidth: true
                Layout.minimumWidth: 0

                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                radius: 16
                color: previousMouse.containsMouse ? Theme.surfaceHover : Theme.surface

                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1

                    text: "‹"
                    color: Theme.text
                    font.pixelSize: 22
                }

                MouseArea {
                    id: previousMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: root.changeMonth(-1)
                }
            }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                radius: 16
                color: nextMouse.containsMouse ? Theme.surfaceHover : Theme.surface

                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1

                    text: "›"
                    color: Theme.text
                    font.pixelSize: 22
                }

                MouseArea {
                    id: nextMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: root.changeMonth(1)
                }
            }
        }

        // Calendar
        Grid {
            id: calendarGrid

            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 7

            columnSpacing: 0
            rowSpacing: 2

            readonly property real cellWidth: width / 7

            // Weekday headers
            Repeater {
                model: root.weekdays

                Text {
                    required property string modelData

                    width: calendarGrid.cellWidth
                    height: 24

                    text: modelData
                    color: Theme.textMuted
                    font.pixelSize: 12
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Days
            Repeater {
                model: root.weeks * 7

                Item {
                    id: dayCell
                    required property int index

                    width: calendarGrid.cellWidth
                    height: 28

                    readonly property int day: index - root.firstDay + 1

                    readonly property bool validDay: day >= 1 && day <= root.days

                    Rectangle {
                        anchors.centerIn: parent

                        width: 28
                        height: 28
                        radius: 14

                        color: dayCell.validDay && root.isToday(dayCell.day) ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: dayCell.validDay ? dayCell.day : ""

                            color: root.isToday(dayCell.day) ? Theme.accentText : Theme.text
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
}
