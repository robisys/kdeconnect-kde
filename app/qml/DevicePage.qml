/*
 * Copyright 2015 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.kirigami 1.0 as Kirigami
import org.kde.kdeconnect 1.0

Kirigami.Page
{
    id: deviceView
    property QtObject currentDevice
    title: currentDevice.name

    actions.contextualActions: deviceLoader.item.actions

    Loader {
        id: deviceLoader
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true

        sourceComponent: deviceView.currentDevice.isTrusted ? trustedDevice : untrustedDevice
        Component {
            id: trustedDevice
            ColumnLayout {
                property list<QtObject> actions: [
                    Kirigami.Action {
                        onTriggered: deviceView.currentDevice.unpair()
                        text: i18n("UnPair")
                    },
                    Kirigami.Action {
                        text: i18n("Send Ping")
                        onTriggered: {
                            deviceView.currentDevice.pluginCall("ping", "sendPing");
                        }
                    }
                ]

                id: trustedView
                Layout.fillHeight: true
                Layout.fillWidth: true

                Kirigami.BasicListItem {
                    readonly property var fu: PluginChecker {
                        id: mprisChecker
                        pluginName: "mpriscontrol"
                    }
                    enabled: mprisChecker.available
                    label: i18n("Multimedia control")
                    onClicked: pageStack.push(
                        "qrc:/qml/mpris.qml",
                        { mprisInterface: MprisDbusInterfaceFactory.create(deviceView.currentDevice.id()) }
                    );
                }
                Kirigami.BasicListItem {
                    readonly property var fu: PluginChecker {
                        id: mousepadChecker
                        pluginName: "mousepad"
                    }
                    enabled: mousepadChecker.available
                    label: i18n("Remote input")
                    onClicked: pageStack.push(
                        "qrc:/qml/mousepad.qml",
                        { remoteControlInterface: RemoteControlDbusInterfaceFactory.create(deviceView.currentDevice.id()) }
                    );
                }
                Kirigami.BasicListItem {
                    readonly property var fu: PluginChecker {
                        id: lockdeviceChecker
                        pluginName: "lockdevice"
                    }
                    enabled: lockdeviceChecker.available
                    property var lockIface: LockDeviceDbusInterfaceFactory.create(deviceView.currentDevice.id())
                    label: lockIface.isLocked ? i18n("Unlock") : i18n("Lock")
                    onClicked: {
                        lockIface.isLocked = !lockIface.isLocked;
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
        Component {
            id: untrustedDevice
            Item {
                readonly property var actions: []
                Button {
                    anchors.centerIn: parent

                    text: i18n("Pair")
                    onClicked: deviceView.currentDevice.requestPair()
                }
            }
        }
    }
}
