import sys
from PyQt6.QtWidgets import QApplication
from src.gui.main_window import MainWindow

def main():
    app = QApplication(sys.argv)
    
    # Set application info
    app.setApplicationName("Kukuri Setup Installer")
    app.setApplicationVersion("1.0.0")
    
    # Create and show main window
    window = MainWindow()
    window.show()
    
    sys.exit(app.exec())

if __name__ == '__main__':
    main()