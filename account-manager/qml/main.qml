import QtQuick 2.12
import QtQuick.Controls 2.14
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
        if (changePasswordNewPassword.text === changePasswordNewPasswordConfirm.text) {
            if (changePasswordNewPassword.text === changePasswordOldPassword.text) {
                newPasswordIsOldPassword.open();
            } else {
                if (changePasswordNewPassword.text === "") {
                    newPasswordIsEmpty.resetButton = changePasswordChangeButton;
                    newPasswordIsEmpty.open();
                } else {
                    if (account.changePassword(changePasswordOldPassword.text, changePasswordNewPassword.text)) {
                        changePasswordChangeButton.enabled = true;
                        changePasswordFrame.visible = false;
                        changePasswordShowButton.enabled = true;
                    } else {
                        changePasswordOldPasswordWrong.open();
                    }
                }
            }
        } else {
            passwordConfirmDoesNotMatch.resetButton = changePasswordChangeButton;
            passwordConfirmDoesNotMatch.open();
        }
    }
    
    function showNewUser() {
        newAccountShowButton.enabled = false;
        refreshDevices();
        newAccountFrame.visible = true;
    }
    
    function refreshDevices() {
        devices.refresh();
        devicesModel.clear();
        for(var i = 0; i < devices.length(); i++) {
            devicesModel.append({
                "index": i,
                "description": devices.getDescription(i),
                "device": devices.getDevice(i)
            });
        }
    }
    
    function createAccount() {
        newAccountCreateButton.enabled = false;
        if (newAccountName.text === "") {
            usernameEmpty.open();
        } else {
            if (newAccountPassword.text === newAccountPasswordConfirm.text) {
                if (newAccountPassword.text === "") {
                    newPasswordIsEmpty.resetButton = newAccountCreateButton;
                    newPasswordIsEmpty.open();
                } else {
                    newAccountCreateConfirm.open();
                }
            } else {
                passwordConfirmDoesNotMatch.resetButton = newAccountCreateButton;
                passwordConfirmDoesNotMatch.open();
            }
        }
    }
    
    Account {
        id: account
    }
    
    Devices {
        id: devices
    }
    
    ListModel {
        id: devicesModel
    }
    
    MessageDialog {
        id: passwordConfirmDoesNotMatch
        buttons: MessageDialog.Ok
        text: qsTr("The two new passwords do not match.")
        property var resetButton: null
        onAccepted: this.resetButton.enabled = true
        onRejected: this.resetButton.enabled = true
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
        property var resetButton: null
        onAccepted: this.resetButton.enabled = true
        onRejected: this.resetButton.enabled = true
    }
    
    MessageDialog {
        id: oldPasswordWrong
        buttons: MessageDialog.Ok
        text: qsTr("The old password was wrong.")
        onAccepted: changePasswordChangeButton.enabled = true
        onRejected: changePasswordChangeButton.enabled = true
    }
    
    MessageDialog {
        id: usernameEmpty
        buttons: MessageDialog.Ok
        text: qsTr("The username is empty.")
        onAccepted: newAccountCreateButton.enabled = true
        onRejected: newAccountCreateButton.enabled = true
    }
    
    MessageDialog {
        id: newAccountCreateConfirm
        text: qsTr(
            "Are you sure to create the account '%1'?\nThis will overwrite the device '%2' (%3)."
        ).arg(
            newAccountName.text
        ).arg(
            devicesModel.get(deviceSelect.currentIndex).description
        ).arg(
            devicesModel.get(deviceSelect.currentIndex).device
        )
        buttons: MessageDialog.Ok | MessageDialog.Cancel
        onAccepted: {
            account.create(
                newAccountName.text,
                newAccountPassword.text,
                devicesModel.get(deviceSelect.currentIndex).device,
            );
            newAccountCreateButton.enabled = true;
            newAccountFrame.visible = false;
            newAccountShowButton.enabled = true;
        }
        onRejected: newAccountCreateButton.enabled = true
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
                     
                    Button {
                        id: newAccountShowButton
                        text: qsTr("New account")
                        onClicked: showNewUser()
                    }
                }
                Frame {
                    id: changePasswordFrame
                    visible: false
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: changePasswordOldPassword
                            echoMode: TextInput.Password
                            placeholderText: qsTr("old password")
                        }
                        TextField {
                            id: changePasswordNewPassword
                            echoMode: TextInput.Password
                            placeholderText: qsTr("new password")
                        }
                        TextField {
                            id: changePasswordNewPasswordConfirm
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
                Frame {
                    id: newAccountFrame
                    visible: false
                    RowLayout {
                        Layout.fillWidth: true
                        TextField {
                            id: newAccountName
                            placeholderText: qsTr("username")
                        }
                        TextField {
                            id: newAccountPassword
                            echoMode: TextInput.Password
                            placeholderText: qsTr("new password")
                        }
                        TextField {
                            id: newAccountPasswordConfirm
                            echoMode: TextInput.Password
                            placeholderText: qsTr("confirm new password")
                        }
                        ComboBox {
                            id: deviceSelect
                            model: devicesModel
                            textRole: "description"
                        }
                        Button {
                            id: newAccountCreateButton
                            text: qsTr("Create account")
                            onClicked: createAccount()
                        }
                    }
                }
            }
        }

    }
}
