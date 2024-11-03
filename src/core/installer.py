import os
import subprocess
from pathlib import Path
from typing import List, Optional, Callable
from PyQt6.QtCore import QObject, pyqtSignal
from ..config import SILENT_INSTALL_ARGS

class InstallationError(Exception):
    """Custom exception for installation errors"""
    pass

class Installer(QObject):
    """Handles the installation process for files"""
    
    progress = pyqtSignal(str)  # Signal for progress updates
    error = pyqtSignal(str)     # Signal for error messages
    
    def __init__(self):
        super().__init__()
        
    def install_file(self, file_path: Path) -> bool:
        """
        Install a single file
        Returns True if installation was successful, False otherwise
        """
        self.progress.emit(f"Installing {file_path.name}...")
        
        # Try silent installation first
        if self._try_silent_install(file_path):
            self.progress.emit(f"Successfully installed {file_path.name}")
            return True
            
        # If silent install failed, try normal installation
        try:
            self.progress.emit(f"Silent installation failed. Attempting normal installation for {file_path.name}")
            result = self._run_normal_install(file_path)
            if result:
                self.progress.emit(f"Successfully installed {file_path.name}")
                return True
        except Exception as e:
            self.error.emit(f"Error installing {file_path.name}: {str(e)}")
            return False
        
        return False
    
    def _try_silent_install(self, file_path: Path) -> bool:
        """Attempt silent installation with various arguments"""
        for args in SILENT_INSTALL_ARGS:
            try:
                cmd = [str(file_path)] + args.split()
                process = subprocess.run(
                    cmd,
                    check=True,
                    capture_output=True,
                    text=True
                )
                if process.returncode == 0 or process.returncode == 3010:
                    return True
            except subprocess.CalledProcessError:
                continue
        return False
    
    def _run_normal_install(self, file_path: Path) -> bool:
        """Run normal installation process"""
        try:
            # For .bat files
            if file_path.suffix.lower() == '.bat':
                process = subprocess.run(
                    [str(file_path)],
                    shell=True,
                    check=True
                )
            # For .exe and .msi files
            else:
                process = subprocess.run(
                    [str(file_path)],
                    check=True
                )
            return process.returncode == 0 or process.returncode == 3010
        except subprocess.CalledProcessError as e:
            self.error.emit(f"Installation failed: {str(e)}")
            return False
        except Exception as e:
            self.error.emit(f"Unexpected error: {str(e)}")
            return False