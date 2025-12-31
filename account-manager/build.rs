use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new_qml_module(
        QmlModule::new("de.chaosdorf.AccountManager")
            .qml_file("qml/main.qml")
    )
        .files(["src/account.rs", "src/devices.rs"])
        .build();
}