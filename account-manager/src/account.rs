
/// The bridge definition for our QObject
#[cxx_qt::bridge]
pub mod qobject {

    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        /// An alias to the QString type
        type QString = cxx_qt_lib::QString;
    }

    extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(QString, name)]
        #[namespace = "account"]
        type Account = super::AccountRust;
    }

    extern "RustQt" {
        // Declare the invokable methods we want to expose on the QObject      
        #[qinvokable]
        #[cxx_name = "changePassword"]
        fn change_password(
            self: &Account, old_password: &QString, new_password: &QString,
        ) -> bool;
        
        #[qinvokable]
        #[cxx_name = "create"]
        fn create(
            self: &Account, username: &QString, password: &QString, device: &QString,
        ) -> bool;
    }
}

use std::process::{Command};
use cxx_qt_lib::QString;
use log::{error, info};
use nix::unistd::{User, Uid};
use rexpect::{session::spawn_command, ReadUntil};
/// The Rust struct for the QObject
pub struct AccountRust {
    name: QString,
}

const GUEST_ACCOUNT_START: &str = "guest-";

impl Default for AccountRust {
    /// Use the current user's name.
    fn default() -> Self {
        let user = User::from_uid(Uid::current());
        Self { name: QString::from(
            user.ok().flatten().map(|u| u.name).unwrap_or("unknown".to_owned())
        ) }
    }
}

impl qobject::Account {
    pub fn change_password(
        &self, old_password: &QString, new_password: &QString,
    ) -> bool {
        assert!(self.name.to_string().starts_with(GUEST_ACCOUNT_START)); // TODO
        info!("changing password");
        // we need to call `passwd` because it is setuid
        // this needs to happen interactively, because `-s` only works for root
        let mut command = Command::new("passwd");
        command.env("LANG", "C.UTF-8");
        let mut passwd = spawn_command(
            command, None,
        ).expect("failed to spawn passwd");
        passwd.exp_string(&format!(
            "Changing password for {}", self.name
        )).expect("failed to find initial message");
        passwd.exp_string("Current password: ")
            .expect("failed to find old password prompt");
        passwd.send_line(&old_password.to_string())
            .expect("failed to send old password");
        let (_read, matched) = passwd.exp_any(vec![
            ReadUntil::String("passwd: Permission denied".to_string()),
            ReadUntil::String("passwd: Authentication token manipulation error".to_string()),
            ReadUntil::String("New password:".to_string()),
        ]).expect("failed to match first response");
        if matched != "New password:" {
            error!("provided old password was wrong");
            return false
        }
        assert_eq!(matched, "New password:");
        passwd.send_line(&new_password.to_string())
            .expect("failed to send new password");
        passwd.exp_string("Retype new password:")
            .expect("failed to send new password");
        passwd.send_line(&new_password.to_string())
            .expect("failed to send new password confirm");
        passwd.exp_string("passwd: password updated successfully")
            .expect("passwd failed to change password");
        true
    }
    
    pub fn create(
        &self, username: &QString, password: &QString, device: &QString,
    ) -> bool {
        // this could be JSON, but homectl accepts no record without hashedPassword
        let username = username.to_string();
        info!("creating new account '{username}' on '{device}'");
        assert!(!username.starts_with(GUEST_ACCOUNT_START));
        let mut command = Command::new("homectl");
        command.env("LANG", "C.UTF-8");
        command.arg("create");
        command.arg(&username);
        command.arg("--enforce-password-policy=no");
        command.arg("--storage=luks");
        command.arg("--fs-type=btrfs");
        command.arg(format!("--image-path={device}"));
        command.arg("--member-of=users");
        command.arg(format!("--real-name={username}"));
        let mut homectl = spawn_command(
            command, None,
        ).expect("failed to spawn homectl");
        homectl.exp_string("Please enter new password for user")
            .expect("failed to wait for password prompt");
        homectl.send_line(&password.to_string())
            .expect("failed to send password");
        homectl.exp_string("Please enter new password for user")
            .expect("failed to wait for password prompt");
        homectl.send_line(&password.to_string())
            .expect("failed to send password");
        true
    }
}
