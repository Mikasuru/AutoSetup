from pathlib import Path
from typing import Dict, List, Set

class FileScanner:
    """Handles scanning directories for installation files"""
    
    @staticmethod
    def scan_all_directories() -> Dict[str, List[Path]]:
        """
        Scan all installation directories for valid files
        Returns a dictionary mapping category names to lists of file paths
        """
        root_dir = Path(__file__).parent.parent.parent
        results = {}
        
        # กำหนดโฟลเดอร์ที่ต้องการสแกน
        target_folders = {
            'Driver': ['Driver', 'driver'],
            'Programs': ['Program', 'program'],
            'Extra Driver': ['Extra Driver', 'extra_driver'],
            'VCRuntime': ['VCRuntime', 'vcruntime']
        }
        
        # สแกนแต่ละโฟลเดอร์
        for display_name, possible_names in target_folders.items():
            for folder_name in possible_names:
                folder_path = root_dir / folder_name
                if folder_path.exists():
                    print(f"Scanning {display_name} folder: {folder_path}")
                    files = FileScanner.scan_directory(folder_path)
                    if files:
                        results[display_name] = files
                    break  # หากพบโฟลเดอร์ที่มีไฟล์แล้ว ให้ข้ามไปโฟลเดอร์ถัดไป
        
        return results

    @staticmethod
    def scan_directory(directory: Path) -> List[Path]:
        """
        Recursively scan a directory for installation files
        """
        files = []
        extensions = ['.exe', '.msi', '.bat']
        
        try:
            # สแกนทุกไฟล์ในโฟลเดอร์และโฟลเดอร์ย่อย
            for ext in extensions:
                # ใช้ rglob เพื่อค้นหาไฟล์ในโฟลเดอร์ย่อยด้วย
                found_files = list(directory.rglob(f"*{ext}"))
                # พิมพ์จำนวนไฟล์ที่พบ
                print(f"Found {len(found_files)} {ext} files in {directory}")
                # พิมพ์รายชื่อไฟล์ที่พบ
                for file in found_files:
                    print(f"    {file}")
                files.extend(found_files)
            
            # เรียงไฟล์ตามชื่อ
            return sorted(files)
            
        except Exception as e:
            print(f"Error scanning directory {directory}: {e}")
            return []