use cxx_qt_build::{CxxQtBuilder, QmlModule};

fn main() {
    CxxQtBuilder::new()
        .qml_module(QmlModule {
            uri: "de.chaosdorf.AccountManager",
            rust_files: &["src/account.rs", "src/devices.rs"],
            qml_files: &["qml/main.qml"],
            ..Default::default()
        })
        .build();
}