from PyQt6.QtWidgets import QTreeWidget, QTreeWidgetItem
from PyQt6.QtCore import Qt, pyqtSlot
from pathlib import Path
from typing import Dict, List, Optional

class FileTreeWidget(QTreeWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()
        self.file_paths = {}
        self._is_updating = False  # ป้องกันการ update ซ้ำซ้อน
        
    def setup_ui(self):
        """Initialize UI components"""
        self.setHeaderLabel("Installation Files")
        self.setMinimumWidth(300)
        self.setColumnCount(1)
        self.setAlternatingRowColors(True)
        self.itemChanged.connect(self._on_item_changed)
        
    def populate_tree(self, file_data: Dict[str, List[Path]]):
        """Build the tree structure from file data"""
        try:
            print("Starting tree population...")
            self.clear()
            self.file_paths.clear()
            
            for category, files in file_data.items():
                print(f"Processing category: {category} with {len(files)} files")
                
                # Create category root item
                category_root = QTreeWidgetItem(self)
                category_root.setText(0, category)
                category_root.setFlags(
                    Qt.ItemFlag.ItemIsEnabled | 
                    Qt.ItemFlag.ItemIsSelectable |
                    Qt.ItemFlag.ItemIsUserCheckable
                )
                category_root.setCheckState(0, Qt.CheckState.Unchecked)
                
                # Group files by subdirectory
                folders = {}
                for file_path in files:
                    folder = str(file_path.parent.relative_to(file_path.parent.parent))
                    if folder not in folders:
                        folders[folder] = []
                    folders[folder].append(file_path)
                
                # Add files to tree
                for folder, folder_files in sorted(folders.items()):
                    if folder == '.' or folder == category:
                        parent = category_root
                    else:
                        # Create folder item
                        folder_item = QTreeWidgetItem(category_root)
                        folder_item.setText(0, folder)
                        folder_item.setFlags(
                            Qt.ItemFlag.ItemIsEnabled | 
                            Qt.ItemFlag.ItemIsSelectable |
                            Qt.ItemFlag.ItemIsUserCheckable
                        )
                        folder_item.setCheckState(0, Qt.CheckState.Unchecked)
                        parent = folder_item
                    
                    # Add files to folder
                    for file_path in sorted(folder_files, key=lambda x: x.name.lower()):
                        file_item = QTreeWidgetItem(parent)
                        file_item.setText(0, file_path.name)
                        file_item.setFlags(
                            Qt.ItemFlag.ItemIsEnabled | 
                            Qt.ItemFlag.ItemIsSelectable |
                            Qt.ItemFlag.ItemIsUserCheckable
                        )
                        file_item.setCheckState(0, Qt.CheckState.Unchecked)
                        self.file_paths[id(file_item)] = file_path
            
            self.expandAll()
            print("Tree population completed")
            
        except Exception as e:
            print(f"Error populating tree: {e}")
            raise

    def _update_parent_recursively(self, item: QTreeWidgetItem):
        """Update parent check state recursively"""
        if not item:
            return
            
        parent = item.parent()
        if not parent:
            return
            
        # Count checked children
        child_count = parent.childCount()
        checked_count = 0
        partial_count = 0
        
        for i in range(child_count):
            child = parent.child(i)
            if child.checkState(0) == Qt.CheckState.Checked:
                checked_count += 1
            elif child.checkState(0) == Qt.CheckState.PartiallyChecked:
                partial_count += 1
        
        # Update parent state
        if checked_count == child_count:
            parent.setCheckState(0, Qt.CheckState.Checked)
        elif checked_count > 0 or partial_count > 0:
            parent.setCheckState(0, Qt.CheckState.PartiallyChecked)
        else:
            parent.setCheckState(0, Qt.CheckState.Unchecked)
        
        # Continue up the tree
        self._update_parent_recursively(parent)

    def _set_children_checked_state(self, item: QTreeWidgetItem, state: Qt.CheckState):
        """Set check state for all children"""
        if not item:
            return
            
        for i in range(item.childCount()):
            child = item.child(i)
            child.setCheckState(0, state)
            self._set_children_checked_state(child, state)
    
    @pyqtSlot(QTreeWidgetItem, int)
    def _on_item_changed(self, item: QTreeWidgetItem, column: int):
        """Handle item check state changes"""
        if self._is_updating or column != 0:
            return
            
        try:
            self._is_updating = True
            
            # Update children
            state = item.checkState(0)
            self._set_children_checked_state(item, state)
            
            # Update parents
            self._update_parent_recursively(item)
            
        finally:
            self._is_updating = False
    
    def get_checked_files(self) -> List[Path]:
        """Get list of checked file paths"""
        checked_files = []
        
        def traverse(item: QTreeWidgetItem):
            if id(item) in self.file_paths and item.checkState(0) == Qt.CheckState.Checked:
                checked_files.append(self.file_paths[id(item)])
            for i in range(item.childCount()):
                traverse(item.child(i))
        
        root = self.invisibleRootItem()
        for i in range(root.childCount()):
            traverse(root.child(i))
            
        return checked_files
    
    def select_all(self):
        """Select all items"""
        try:
            self._is_updating = True
            root = self.invisibleRootItem()
            for i in range(root.childCount()):
                item = root.child(i)
                item.setCheckState(0, Qt.CheckState.Checked)
                self._set_children_checked_state(item, Qt.CheckState.Checked)
        finally:
            self._is_updating = False
    
    def deselect_all(self):
        """Deselect all items"""
        try:
            self._is_updating = True
            root = self.invisibleRootItem()
            for i in range(root.childCount()):
                item = root.child(i)
                item.setCheckState(0, Qt.CheckState.Unchecked)
                self._set_children_checked_state(item, Qt.CheckState.Unchecked)
        finally:
            self._is_updating = False