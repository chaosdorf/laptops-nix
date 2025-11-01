# Don't run this file, run `qmlscene main.qml`.
import logging
logger = logging.getLogger(__name__)
from getpass import getuser
from pexpect import spawn

def change_password(old_password: str, new_password: str) -> bool:
    logger.info("changing password");
    # we need to call `passwd` because it is setuid
    # this needs to happen interactively, because `-s` only works for root
    passwd = spawn("passwd", env={"LANG": "C.UTF-8"})
    passwd.expect(f"Changing password for {getuser()}")
    passwd.expect("Current password: ")
    passwd.sendline(old_password)
    if passwd.expect([
        "passwd: Permission denied",
        "passwd: Authentication token manipulation error",
        "New password:",
    ]) != 2:
        logger.error("provided old password was wrong");
        return False
    passwd.sendline(new_password)
    passwd.expect("Retype new password:")
    passwd.sendline(new_password)
    passwd.expect("passwd: password updated successfully")
    return True

def create_account(name: str, password: str) -> bool:
    # this could be JSON, but homectl accepts no record without hashedPassword
    logger.info("creating new account")
    homectl = spawn(
        "/run/current-system/sw/bin/homectl",
        ["create", name, "--enforce-password-policy=no"],
        env={"LANG": "UTF-8"},
    )
    # TODO: USB drive
    homectl.expect("Please enter new password for user")
    homectl.sendline(password)
    homectl.expect("Please enter new password for user")
    homectl.sendline(password)
    return True

if __name__ == "__main__":
    import sys
    from pathlib import Path
    qml_path = Path(__file__).with_name("main.qml")
    from PySide6.QtCore import Qt
    from PySide6.QtQml import QQmlApplicationEngine
    from PySide6.QtWidgets import QApplication, QLabel
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()
    engine.load(qml_path)
    sys.exit(app.exec())
