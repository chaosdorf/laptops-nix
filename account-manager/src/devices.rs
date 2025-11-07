
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
        #[namespace = "device"]
        type Devices = super::DevicesRust;
    }

    extern "RustQt" {
        // Declare the invokable methods we want to expose on the QObject      
        #[qinvokable]
        #[cxx_name = "refresh"]
        fn refresh(self: &Devices);
        
        #[qinvokable]
        #[cxx_name = "length"]
        fn length(self: &Devices) -> usize;
        
        #[qinvokable]
        #[cxx_name = "getDevice"]
        fn get_device(self: &Devices, index: usize) -> QString;
        
        #[qinvokable]
        #[cxx_name = "getDescription"]
        fn get_description(self: &Devices, index: usize) -> QString;
    }
}

use std::sync::Mutex;
use bb_drivelist::{DeviceDescriptor, drive_list};
use cxx_qt_lib::QString;
use log::{error, info};

/// The Rust struct for the QObject
#[derive(Default)]
pub struct DevicesRust {
    devices: Mutex<Vec<DeviceDescriptor>>,
}

impl qobject::Devices {
    pub fn refresh(&self) {
        let mut lock = self.devices.lock().expect("failed to get lock");
        info!("searching for devices");
        lock.clear();
        lock.extend(drive_list()
            .expect("failed to get device list")
            .into_iter()
            .inspect(|d| info!("found {:?} (removable: {})", d, d.is_removable))
            .filter(|d| d.is_removable)
        );
    }
    
    pub fn length(&self) -> usize {
        self
            .devices
            .lock()
            .expect("failed to get lock")
            .len()
    }
    
    pub fn get_device(&self, index: usize) -> QString {
        QString::from(
            &self
            .devices
            .lock()
            .expect("failed to get lock")
            [index]
            .device
        )
    }
    
    pub fn get_description(&self, index: usize) -> QString {
        QString::from(
            &self
            .devices
            .lock()
            .expect("failed to get lock")
            [index]
            .description
        )
    }
}
