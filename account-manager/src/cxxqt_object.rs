
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
        fn change_password(self: Pin<&mut Account>);
    }
}

use core::pin::Pin;
use cxx_qt_lib::QString;

/// The Rust struct for the QObject
pub struct AccountRust {
    name: QString,
}

impl Default for  AccountRust {
    fn default() -> Self {
        Self { name: QString::from("bar") }
    }
}

impl qobject::Account {
    pub fn change_password(self: Pin<&mut Self>) {
        todo!()
    }
}
