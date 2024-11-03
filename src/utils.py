import os
import sys
import psutil
import platform
import json
import logging
import shutil
from pathlib import Path
from typing import Dict, List, Optional, Union
from datetime import datetime
from .config import (
    SYSTEM_REQUIREMENTS, 
    STATE_FILE, 
    LOG_CONFIG,
    KNOWN_APPS
)

class SystemChecker:
    """Utility class for checking system requirements and compatibility"""
    
    @staticmethod
    def check_system_requirements() -> Dict[str, bool]:
        """Check if system meets minimum requirements"""
        results = {
            'memory': SystemChecker.check_memory(),
            'disk_space': SystemChecker.check_disk_space(),
            'os_version': SystemChecker.check_os_version()
        }
        return results
    
    @staticmethod
    def check_memory() -> bool:
        """Check if system has enough RAM"""
        system_memory = psutil.virtual_memory().total
        return system_memory >= SYSTEM_REQUIREMENTS['min_memory']
    
    @staticmethod
    def check_disk_space() -> bool:
        """Check if system has enough free disk space"""
        free_space = psutil.disk_usage('/').free
        return free_space >= SYSTEM_REQUIREMENTS['min_disk_space']
    
    @staticmethod
    def check_os_version() -> bool:
        """Check if OS is supported"""
        os_name = platform.system()
        if os_name != 'Windows':
            return False
        
        win_ver = platform.win32_ver()[0]
        return any(ver in win_ver for ver in SYSTEM_REQUIREMENTS['supported_os'])

class StateManager:
    """Manages persistent application state"""
    
    @staticmethod
    def save_state(state: Dict) -> bool:
        """Save application state to file"""
        try:
            with open(STATE_FILE, 'w') as f:
                json.dump(state, f)
            return True
        except Exception as e:
            logging.error(f"Failed to save state: {e}")
            return False
    
    @staticmethod
    def load_state() -> Dict:
        """Load application state from file"""
        if not STATE_FILE.exists():
            return {}
            
        try:
            with open(STATE_FILE, 'r') as f:
                return json.load(f)
        except Exception as e:
            logging.error(f"Failed to load state: {e}")
            return {}

class FileUtils:
    """Utility functions for file operations"""
    
    @staticmethod
    def get_file_info(file_path: Path) -> Dict:
        """Get detailed information about a file"""
        return {
            'name': file_path.name,
            'size': file_path.stat().st_size,
            'modified': datetime.fromtimestamp(file_path.stat().st_mtime),
            'is_installer': FileUtils.is_installer(file_path),
            'type': FileUtils.get_file_type(file_path)
        }
    
    @staticmethod
    def is_installer(file_path: Path) -> bool:
        """Check if file is an installer"""
        return file_path.suffix.lower() in ['.exe', '.msi', '.bat']
    
    @staticmethod
    def get_file_type(file_path: Path) -> str:
        """Get the type of installer"""
        name_lower = file_path.name.lower()
        
        for app_type, info in KNOWN_APPS.items():
            if any(pattern in name_lower for pattern in info['patterns']):
                return app_type
                
        return 'unknown'
    
    @staticmethod
    def format_size(size_bytes: int) -> str:
        """Format file size in human readable format"""
        for unit in ['B', 'KB', 'MB', 'GB']:
            if size_bytes < 1024:
                return f"{size_bytes:.2f} {unit}"
            size_bytes /= 1024
        return f"{size_bytes:.2f} TB"

class LogManager:
    """Manages application logging"""
    
    @staticmethod
    def setup_logging():
        """Setup logging configuration"""
        logging.basicConfig(
            filename=LOG_CONFIG['filename'],
            level=logging.INFO,
            format=LOG_CONFIG['format'],
            datefmt=LOG_CONFIG['date_format']
        )
        
        # Also log to console in debug mode
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.DEBUG)
        formatter = logging.Formatter(LOG_CONFIG['format'])
        console_handler.setFormatter(formatter)
        logging.getLogger().addHandler(console_handler)
    
    @staticmethod
    def log_system_info():
        """Log system information"""
        logging.info("=== System Information ===")
        logging.info(f"OS: {platform.platform()}")
        logging.info(f"Python: {sys.version}")
        logging.info(f"CPU: {platform.processor()}")
        memory = psutil.virtual_memory()
        logging.info(f"Memory: Total={FileUtils.format_size(memory.total)}, "
                    f"Available={FileUtils.format_size(memory.available)}")
        disk = psutil.disk_usage('/')
        logging.info(f"Disk: Total={FileUtils.format_size(disk.total)}, "
                    f"Free={FileUtils.format_size(disk.free)}")

def is_admin() -> bool:
    """Check if application is running with admin privileges"""
    try:
        return os.getuid() == 0
    except AttributeError:
        import ctypes
        return ctypes.windll.shell32.IsUserAnAdmin() != 0

def run_as_admin():
    """Restart the application with admin privileges"""
    if not is_admin():
        import ctypes
        import sys
        
        # Restart the program with admin rights
        ctypes.windll.shell32.ShellExecuteW(
            None, 
            "runas", 
            sys.executable, 
            " ".join(sys.argv), 
            None, 
            1
        )
        sys.exit(0)

def create_backup(file_path: Path, backup_dir: Optional[Path] = None) -> Optional[Path]:
    """Create a backup of a file"""
    if not file_path.exists():
        return None
        
    if backup_dir is None:
        backup_dir = file_path.parent / 'backups'
        
    backup_dir.mkdir(exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_path = backup_dir / f"{file_path.stem}_{timestamp}{file_path.suffix}"
    
    try:
        shutil.copy2(file_path, backup_path)
        return backup_path
    except Exception as e:
        logging.error(f"Failed to create backup: {e}")
        return None