pub mod cxxqt_object;

use cxx_qt_lib::{QGuiApplication, QString, QQmlApplicationEngine, QUrl};

fn main() {
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
        app.exec();
    }
}
