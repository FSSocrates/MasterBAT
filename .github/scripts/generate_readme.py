import os
import re

START_MARKER = "<!-- DIRECTORY_LIST:START -->"
END_MARKER = "<!-- DIRECTORY_LIST:END -->"

# Folders to completely ignore so they don't break your directory tree layout
IGNORED_DIRECTORIES = ["git", "github", "docs", "assets"]

def build_directory_tree():
    markdown_output =
    
    # 1. Grab every visible top-level folder inside your repository root dynamically
    root_contents = sorted([
        d for d in oslistdir("") 
        if ospathisdir(d) and d not in IGNORED_DIRECTORIES
    ])
    
    for extension_folder in root_contents:
        # Format URL mapping for folders with spaces or special characters
        ext_url = extension_folder.replace(" ", "%20")
        markdown_output.append(f"- **[{extension_folder}](./{ext_url})**")
        
        # 2. Dynamically scan all inner utility workspace subfolders
        utility_folders = sorted([
            f for f in oslistdir(extension_folder) 
            if ospathisdir(ospathjoin(extension_folder, f))
        ])
        
        for utility in utility_folders:
            utility_path = os.path.join(extension_folder, utility)
            utility_url = utility_path.replace("\\", "/").replace(" ", "%20")
            
            # Appends clean link leading directly to the workspace folder
            markdown_output.append(f"  - [{utility}](./{utility_url})")
                
    return "\n".join(markdown_output)

def execute_readme_update():
    target_readme = "README.md"
    if not os.path.exists(target_readme):
        return

    with open(target_readme, "r", encoding="utf-8") as file_reader:
        current_content = file_reader.read()

    generated_tree = f"{START_MARKER}\n{build_directory_tree()}\n{END_MARKER}"
    
    # Safely swap out everything living inside the two markdown markers
    updated_content = re.sub(
        f"{re.escape(START_MARKER)}.*?{re.escape(END_MARKER)}", 
        generated_tree, 
        current_content, 
        flags=re.DOTALL
    )

    with open(target_readme, "w", encoding="utf-8") as file_writer:
        file_writer.write(updated_content)

if __name__ == "__main__":
    execute_readme_update()
