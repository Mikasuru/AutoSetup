from PyQt6.QtWidgets import (QWidget, QVBoxLayout, QProgressBar, 
                           QScrollArea, QLabel, QPlainTextEdit)
from PyQt6.QtCore import Qt
from ..config import COLORS

class ProgressWidget(QWidget):
    """Widget for displaying installation progress and logs"""
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()
        
    def setup_ui(self):
        """Setup the progress widget UI"""
        layout = QVBoxLayout(self)
        
        # Log area
        self.log_area = QPlainTextEdit()
        self.log_area.setReadOnly(True)
        self.log_area.setMaximumBlockCount(1000)  # Limit number of lines for performance
        self.log_area.setStyleSheet(f"""
            QPlainTextEdit {{
                background-color: {COLORS['dark_background']};
                color: {COLORS['text']};
                border: none;
            }}
        """)
        layout.addWidget(self.log_area)
        
        # Progress bar
        self.progress_bar = QProgressBar()
        self.progress_bar.setTextVisible(True)
        self.progress_bar.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.progress_bar.setStyleSheet(f"""
            QProgressBar {{
                border: 1px solid {COLORS['text']};
                border-radius: 3px;
                text-align: center;
                background-color: {COLORS['dark_background']};
            }}
            QProgressBar::chunk {{
                background-color: {COLORS['highlight']};
            }}
        """)
        layout.addWidget(self.progress_bar)
        
    def add_log_message(self, message: str, level: str = 'info'):
        """Add a message to the log area with optional level (info, error, success)"""
        color = {
            'info': COLORS['text'],
            'error': COLORS['error'],
            'success': COLORS['success'],
            'warning': COLORS['warning']
        }.get(level, COLORS['text'])
        
        self.log_area.appendHtml(f'<span style="color: {color};">{message}</span>')
        
    def set_progress(self, value: int):
        """Set the progress bar value (0-100)"""
        self.progress_bar.setValue(value)
        
    def reset(self):
        """Reset the progress widget"""
        self.log_area.clear()
        self.progress_bar.setValue(0)