pub mod account;
pub mod devices;

use std::env::VarError;

use cxx_qt_lib::{QGuiApplication, QString, QQmlApplicationEngine, QUrl};
use log::info;

fn main() {
    if let Err(VarError::NotPresent) = std::env::var("RUST_LOG") {
        unsafe { std::env::set_var("RUST_LOG", "debug") };
    }
    env_logger::init();
    
    // Create the application and engine
    let mut app = QGuiApplication::new();
    let mut engine = QQmlApplicationEngine::new();
    
    // To associate the executable to the installed desktop file
    QGuiApplication::set_desktop_file_name(&QString::from("de.chaosdorf.AccountManager"));

    // Load the QML path into the engine
    if let Some(engine) = engine.as_mut() {
        engine.load(&QUrl::from("qrc:/qt/qml/de/chaosdorf/AccountManager/qml/main.qml"));
    }

    if let Some(engine) = engine.as_mut() {
        // Listen to a signal from the QML Engine
        engine
            .as_qqmlengine()
            .on_quit(|_| {
                println!("QML Quit!");
            })
            .release();
    }

    // Start the app
    if let Some(app) = app.as_mut() {
        info!("Transferring control to Qt");
        app.exec();
    }
}
