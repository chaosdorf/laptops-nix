import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 2.12
import QtQuick.Window 2.12

// This must match the uri and version
// specified in the qml_module in the build.rs script.
import de.chaosdorf.AccountManager 1.0

ApplicationWindow {
    height: 480
    title: qsTr("Account Manager")
    visible: true
    width: 640
    color: palette.window
    
    function showChangePassword() {
        changePasswordFrame.visible = true;
        changePasswordShowButton.enabled = false;
    }
    
    function changePassword() {
        changePasswordFrame.visible = false;
        changePasswordShowButton.enabled = true;
    }

    Account {
        id: account
    }

    Column {
        Layout.fillWidth: true
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        Frame {
            Layout.fillWidth: true
            
            ColumnLayout {
                RowLayout {
                    Layout.fillWidth: true
                    
                    Label {
                        text: qsTr("Hi, %1!").arg(account.name)
                        color: palette.text
                    }
            
                    Button {
                        id: changePasswordShowButton
                        text: qsTr("Change password")
                        onClicked: showChangePassword()
                    }
                    
                    // TODO: change name
                }
                Frame {
                    id: changePasswordFrame
                    visible: false
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: oldPassword
                            placeholderText: qsTr("old password")
                        }
                        TextField {
                            id: newPassword
                            placeholderText: qsTr("new password")
                        }
                        TextField {
                            id: newPasswordConfirm
                            placeholderText: qsTr("confirm new password")
                        }
                        Button {
                            text: qsTr("Change password")
                            onClicked: changePassword()
                        }
                    }
                }
            }
        }

    }
}
