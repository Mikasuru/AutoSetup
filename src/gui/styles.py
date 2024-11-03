from PyQt6.QtGui import QPalette, QColor
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QWidget
from ..config import COLORS

def apply_theme(widget: QWidget):
    """Apply dark theme to widget and all its children"""
    palette = QPalette()
    
    # Set color roles
    palette.setColor(QPalette.ColorRole.Window, QColor(COLORS['background']))
    palette.setColor(QPalette.ColorRole.WindowText, QColor(COLORS['text']))
    palette.setColor(QPalette.ColorRole.Base, QColor(COLORS['dark_background']))
    palette.setColor(QPalette.ColorRole.AlternateBase, QColor(COLORS['background']))
    palette.setColor(QPalette.ColorRole.ToolTipBase, QColor(COLORS['text']))
    palette.setColor(QPalette.ColorRole.ToolTipText, QColor(COLORS['text']))
    palette.setColor(QPalette.ColorRole.Text, QColor(COLORS['text']))
    palette.setColor(QPalette.ColorRole.Button, QColor(COLORS['button']))
    palette.setColor(QPalette.ColorRole.ButtonText, QColor(COLORS['button_text']))
    palette.setColor(QPalette.ColorRole.Link, QColor(COLORS['highlight']))
    palette.setColor(QPalette.ColorRole.Highlight, QColor(COLORS['highlight']))
    palette.setColor(QPalette.ColorRole.HighlightedText, QColor(COLORS['dark_background']))
    
    widget.setPalette(palette)

def create_button_style() -> str:
    """Create stylesheet for buttons"""
    return f"""
        QPushButton {{
            background-color: {COLORS['background']};
            color: {COLORS['text']};
            border: 1px solid {COLORS['highlight']};
            border-radius: 3px;
            padding: 5px;
        }}
        
        QPushButton:hover {{
            background-color: {COLORS['highlight']};
            color: {COLORS['dark_background']};
        }}
        
        QPushButton:pressed {{
            background-color: {COLORS['dark_background']};
            border-color: {COLORS['text']};
        }}
        
        QPushButton:disabled {{
            background-color: {COLORS['dark_background']};
            color: #666666;
            border-color: #666666;
        }}
    """

def create_tree_style() -> str:
    """Create stylesheet for tree widget"""
    return f"""
        QTreeWidget {{
            background-color: {COLORS['dark_background']};
            color: {COLORS['text']};
            border: none;
        }}
        
        QTreeWidget::item {{
            padding: 5px;
        }}
        
        QTreeWidget::item:selected {{
            background-color: {COLORS['highlight']};
            color: {COLORS['dark_background']};
        }}
        
        QTreeWidget::item:hover {{
            background-color: {QColor(COLORS['highlight']).lighter(150).name()};
        }}
    """