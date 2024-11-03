import os
from PyQt6.QtWidgets import (QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
                           QPushButton, QLabel, QMessageBox, QSplitter)
from PyQt6.QtCore import Qt, QThread
from PyQt6.QtGui import QFont, QPalette
from typing import List, Optional
from pathlib import Path

from .file_tree import FileTreeWidget
from .progress import ProgressWidget
from ..core.installer import Installer
from ..core.file_scanner import FileScanner
from ..config import WINDOW_TITLE, WINDOW_MIN_SIZE, COLORS
from .styles import apply_theme, create_button_style

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.installer = Installer()
        self.setup_ui()
        self.setup_connections()
        self.scan_files()
        
    def setup_ui(self):
        """Setup the main window UI"""
        self.setWindowTitle(WINDOW_TITLE)
        self.setMinimumSize(*WINDOW_MIN_SIZE)
        
        # Create central widget and main layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        layout = QVBoxLayout(central_widget)
        
        # Title
        title = QLabel(WINDOW_TITLE)
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title_font = QFont()
        title_font.setPointSize(16)
        title_font.setBold(True)
        title.setFont(title_font)
        layout.addWidget(title)
        
        # Create splitter for tree and progress
        splitter = QSplitter(Qt.Orientation.Horizontal)
        
        # Left side - File Tree and Buttons
        tree_widget = QWidget()
        tree_layout = QVBoxLayout(tree_widget)
        
        # File Tree
        self.file_tree = FileTreeWidget()
        tree_layout.addWidget(self.file_tree)
        
        # Buttons
        button_layout = QHBoxLayout()
        
        self.select_all_btn = QPushButton("Select All")
        self.deselect_all_btn = QPushButton("Deselect All")
        self.install_btn = QPushButton("Install Selected")
        
        for btn in [self.select_all_btn, self.deselect_all_btn, self.install_btn]:
            btn.setStyleSheet(create_button_style())
            btn.setMinimumHeight(30)
            button_layout.addWidget(btn)
            
        tree_layout.addLayout(button_layout)
        
        # Right side - Progress Widget
        self.progress_widget = ProgressWidget()
        
        # Add widgets to splitter
        splitter.addWidget(tree_widget)
        splitter.addWidget(self.progress_widget)
        
        layout.addWidget(splitter)
        
        # Apply theme
        apply_theme(self)
        
    def setup_connections(self):
        """Setup signal/slot connections"""
        self.select_all_btn.clicked.connect(self.file_tree.select_all)
        self.deselect_all_btn.clicked.connect(self.file_tree.deselect_all)
        self.install_btn.clicked.connect(self.start_installation)
        
        # Installer connections
        self.installer.progress.connect(self.handle_progress)
        self.installer.error.connect(self.handle_error)
        
    def scan_files(self):
        """Scan for installation files"""
        try:
            files = FileScanner.scan_all_directories()
            self.file_tree.populate_tree(files)
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error scanning files: {str(e)}")
            
    def start_installation(self):
        """Start installation of selected files"""
        files = self.file_tree.get_checked_files()
        
        if not files:
            QMessageBox.warning(self, "Warning", "No files selected for installation")
            return
            
        reply = QMessageBox.question(
            self,
            "Confirm Installation",
            f"Install {len(files)} selected items?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        
        if reply == QMessageBox.StandardButton.Yes:
            self.disable_interface()
            self.progress_widget.reset()
            self.install_files(files)
            
    def install_files(self, files: List[Path]):
        """Install the selected files"""
        total = len(files)
        for i, file in enumerate(files, 1):
            success = self.installer.install_file(file)
            progress = int((i / total) * 100)
            self.progress_widget.set_progress(progress)
            
        self.installation_complete()
            
    def installation_complete(self):
        """Handle installation completion"""
        self.enable_interface()
        self.progress_widget.add_log_message("Installation Complete!", "success")
        
        reply = QMessageBox.question(
            self,
            "Restart Required",
            "Some installations may require a restart. Restart now?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        
        if reply == QMessageBox.StandardButton.Yes:
            os.system('shutdown /r /t 0')
            
    def disable_interface(self):
        """Disable interface during installation"""
        self.select_all_btn.setEnabled(False)
        self.deselect_all_btn.setEnabled(False)
        self.install_btn.setEnabled(False)
        self.file_tree.setEnabled(False)
        
    def enable_interface(self):
        """Enable interface after installation"""
        self.select_all_btn.setEnabled(True)
        self.deselect_all_btn.setEnabled(True)
        self.install_btn.setEnabled(True)
        self.file_tree.setEnabled(True)
        
    def handle_progress(self, message: str):
        """Handle progress messages from installer"""
        self.progress_widget.add_log_message(message)
        
    def handle_error(self, message: str):
        """Handle error messages from installer"""
        self.progress_widget.add_log_message(message, "error")
        QMessageBox.critical(self, "Error", message)