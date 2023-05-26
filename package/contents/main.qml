import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

Item {
    property string displayName: "BT Lights Widget"
    property int spacing: PlasmaCore.Units.gridUnit / 2
    property int buttonRadius: PlasmaCore.Units.gridUnit

    property var bluetoothLightsMacAddresses: [
        // put MAC addresses here before installing; example of a MAC address: "01:23:45:AB:CD:EF"
    ]
    property var colorPresets: [
        "ff0000",
        "ff4400",
        "ffff00",
        "00ff22",
        "00ff88",
        "00bbff",
        "0000ff",
        "bb00ff",
        "ffffff",
        "000000"
    ]

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: PlasmaExtras.Representation {
        contentItem: ColumnLayout {
            Rectangle {
                height: PlasmaCore.Units.smallSpacing
            }
            RowLayout {
                Rectangle {
                    width: PlasmaCore.Units.smallSpacing
                }
                data: Repeater { 
                    model: colorPresets
                    delegate: RowLayout {
                        property var colorHex: modelData
                        Rectangle {
                            width: PlasmaCore.Units.gridUnit
                            height: PlasmaCore.Units.gridUnit
                            radius: width / 2
                            color: Qt.rgba(
                                parseInt(colorHex.substring(0,2), 16) / 255, 
                                parseInt(colorHex.substring(2,4), 16) / 255, 
                                parseInt(colorHex.substring(4,6), 16) / 255, 
                                1
                            )
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    genericBluetoothLightsColorSetter.setColor(colorHex)
                                }
                            }
                        }
                        Rectangle {
                            width: PlasmaCore.Units.smallSpacing
                        }
                    }
                }
            }
            Rectangle {
                height: PlasmaCore.Units.smallSpacing
            }
        }

        MessageDialog {
            id: errorDialog
            title: "Configuration is incomplete"
            text: "Bluetooth MAC addresses or color presets are not configured in the source code. Please configure and rebuild."
            icon: StandardIcon.Critical
        }
        Component.onCompleted: {
            if (bluetoothLightsMacAddresses.length === 0 || colorPresets.length === 0) {
                errorDialog.visible = true
            }
        }    
    }

    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: Plasmoid.icon
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onClicked: {
                if (mouse.button === Qt.LeftButton) {
                    plasmoid.expanded = !plasmoid.expanded
                }
            }
        }
    }

    PlasmaCore.DataSource {
        id: genericBluetoothLightsColorSetter
        engine: "executable"
        onNewData: {
            disconnectSource(sourceName)
        }
        function setColor(colorString) {
            var characteristicHex = "0x0009"
            var valueHex = `56${colorString}00f0aa`
            for (var i= 0; i < bluetoothLightsMacAddresses.length; ++i) {
                connectSource(`gatttool -b ${bluetoothLightsMacAddresses[i]} --char-write-req -a ${characteristicHex} -n ${valueHex}`)
            }
        }
    }
}
