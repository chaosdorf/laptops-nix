import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 6.3
import QtQuick.Layouts 2.12
import QtQuick.Window 2.12
import io.thp.pyotherside 1.4

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
                    py.call(
                        "account_manager.change_password",
                        [changePasswordOldPassword.text, changePasswordNewPassword.text],
                        function (result) {
                            if (result) {
                                changePasswordChangeButton.enabled = true;
                                changePasswordFrame.visible = false;
                                changePasswordShowButton.enabled = true;
                            } else {
                                oldPasswordWrong.open();
                            }
                        }
                    )
                }
            }
        } else {
            passwordConfirmDoesNotMatch.resetButton = changePasswordChangeButton;
            passwordConfirmDoesNotMatch.open();
        }
    }
    
    function showNewUser() {
        newAccountFrame.visible = true;
        newAccountShowButton.enabled = false;
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
                    py.call(
                        "account_manager.create",
                        [newAccountName.text, newAccountPassword.text],
                        function(result) {
                            newAccountCreateButton.enabled = true;
                            newAccountFrame.visible = false;
                            newAccountShowButton.enabled = true;
                        }
                    );
                }
            } else {
                passwordConfirmDoesNotMatch.resetButton = newAccountCreateButton;
                passwordConfirmDoesNotMatch.open();
            }
        }
    }

    Python {
        id: py
        Component.onCompleted: {
            // Add the directory of this .qml file to the search path
            addImportPath(Qt.resolvedUrl('.'));
            // Import the main module and load the data
            importModule('account_manager', null);
        }
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
                        text: {
                            // can't use account_manager here,
                            // because it might not be import yet
                            py.importModule_sync("getpass");
                            return qsTr("Hi, %1!").arg(py.call_sync("getpass.getuser"));
                        }
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
