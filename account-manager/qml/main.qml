import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 6.3
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
        changePasswordChangeButton.enabled = false;
        if (newPassword.text === newPasswordConfirm.text) {
            if (newPassword.text === oldPassword.text) {
                newPasswordIsOldPassword.open();
            } else {
                if (newPassword.text === "") {
                    newPasswordIsEmpty.open();
                } else {
                    if (account.changePassword(oldPassword.text, newPassword.text)) {
                        changePasswordChangeButton.enabled = true;
                        changePasswordFrame.visible = false;
                        changePasswordShowButton.enabled = true;
                    } else {
                        oldPasswordWrong.open();
                    }
                }
            }
        } else {
            passwordConfirmDoesNotMatch.open();
        }
    }

    Account {
        id: account
    }
    
    MessageDialog {
        id: passwordConfirmDoesNotMatch
        buttons: MessageDialog.Ok
        text: qsTr("The two new passwords do not match.")
        onAccepted: changePasswordChangeButton.enabled = true
        onRejected: changePasswordChangeButton.enabled = true
    }
    
    MessageDialog {
        id: newPasswordIsOldPassword
        buttons: MessageDialog.Ok
        text: qsTr("The new password is old.")
        onAccepted: changePasswordChangeButton.enabled = true
        onRejected: changePasswordChangeButton.enabled = true
    }
    
    MessageDialog {
        id: newPasswordIsEmpty
        buttons: MessageDialog.Ok
        text: qsTr("The new password is empty.")
        onAccepted: changePasswordChangeButton.enabled = true
        onRejected: changePasswordChangeButton.enabled = true
    }
    
    MessageDialog {
        id: oldPasswordWrong
        buttons: MessageDialog.Ok
        text: qsTr("The old password was wrong.")
        onAccepted: changePasswordChangeButton.enabled = true
        onRejected: changePasswordChangeButton.enabled = true
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
                        Layout.fillWidth: true
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
                            echoMode: TextInput.Password
                            placeholderText: qsTr("old password")
                        }
                        TextField {
                            id: newPassword
                            echoMode: TextInput.Password
                            placeholderText: qsTr("new password")
                        }
                        TextField {
                            id: newPasswordConfirm
                            echoMode: TextInput.Password
                            placeholderText: qsTr("confirm new password")
                        }
                        Button {
                            id: changePasswordChangeButton
                            text: qsTr("Change password")
                            onClicked: changePassword()
                        }
                    }
                }
            }
        }

    }
}
