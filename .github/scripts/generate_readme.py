import os
import re

START_MARKER = "<!-- DIRECTORY_LIST:START -->"
END_MARKER = "<!-- DIRECTORY_LIST:END -->"

# Define the folders we want to track at the root level (Ignore hidden folders like .github)
VALID_ENVIRONMENTS = ["Windows batch files", "PowerShell scripts", "Python scripts"]

def generate_markdown_tree():
    markdown_lines =
    
    for env in sorted(VALID_ENVIRONMENTS):
        if not os.path.exists(env):
            continue
            
        # Format the top-level path (encoding spaces as %20 for Markdown URLs)
        env_url = env.replace(" ", "%20")
        markdown_lines.append(f"- **[{env}](./{env})**")
        
        # Scan sub-level categories
        categories = sorted([c for c in oslistdir(env) if ospathisdir(ospathjoin(env, c))])
        for cat in categories:
            cat_path = os.path.join(env, cat)
            cat_url = cat_path.replace(" ", "%20").replace("\\", "/")
            markdown_lines.append(f"  - **[{cat}](./{cat_url})**")
            
            # Scan files inside category
            files = sorted([f for f in oslistdir(cat_path) if ospathisfile(ospathjoin(cat_path, f))])
            for file in files:
                # We want to link directly to the runnable script files, not the inner helper readmes
                if file.lower() == "readme.md":
                    continue
                file_path = os.path.join(cat_path, file)
                file_url = file_path.replace(" ", "%20").replace("\\", "/")
                
                # Append the clean hyperlink line
                markdown_lines.append(f"    - [{file}](./{file_url})")
                
    return "\n".join(markdown_lines)

def update_readme():
    readme_path = "README.md"
    if not os.path.exists(readme_path):
        return

    with open(readme_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Generate the fresh layout text
    fresh_tree = f"{START_MARKER}\n{generate_markdown_tree()}\n{END_MARKER}"
    
    # Use Regex to swap the data cleanly between the markers
    pattern = re.escape(START_MARKER) + r"(.*External|.*)" + re.escape(END_MARKER)
    updated_content = re.sub(f"{re.escape(START_MARKER)}.*?{re.escape(END_MARKER)}", fresh_tree, content, flags=re.DOTALL)

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(updated_content)

if __name__ == "__main__":
    update_readme()
