# Application Information
APP_NAME = "Kukuri Setup Installer"
APP_VERSION = "1.0.0"

# Directory Settings
from pathlib import Path
ROOT_DIR = Path(__file__).parent.parent

# UI Settings
WINDOW_TITLE = APP_NAME
WINDOW_MIN_SIZE = (1024, 768)

# Installation Settings
SILENT_INSTALL_ARGS = [
    "/silent /norestart",
    "/quiet /norestart",
    "/verysilent /norestart",
    "/s /norestart",
    "-silent -norestart",
    "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP-",
    "/SILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP-"
]

# Theme Colors
COLORS = {
    # Main colors
    'background': '#2E2E2E',
    'dark_background': '#1E1E1E',
    'text': '#FFFFFF',
    'text_secondary': '#B0B0B0',
    
    # UI elements
    'button': '#3E3E3E',
    'button_hover': '#4E4E4E',
    'button_pressed': '#2A2A2A',
    'button_text': '#FFFFFF',
    
    # Highlights and accents
    'highlight': '#007ACC',
    'highlight_hover': '#1C8DD9',
    'accent': '#FF7F50',
    
    # Status colors
    'success': '#4CAF50',
    'error': '#F44336',
    'warning': '#FFA726',
    'info': '#29B6F6',
    
    # Tree view
    'tree_alternate': '#2A2A2A',
    'tree_selected': '#007ACC',
    'tree_hover': '#3E3E3E'
}