#!/usr/bin/env python3
"""
Create New Project Script

Create a new project from the template.

Usage:
    python scripts/create_new_project.py "2024-my-project"
    python scripts/create_new_project.py "2024-my-project" --author "John Doe"
"""

import argparse
import shutil
import sys
from pathlib import Path
from datetime import datetime
import re


# Add lib to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from lib import REPO_ROOT


def validate_project_name(name: str) -> bool:
    """Validate project name format."""
    # Should match pattern: YYYY-description
    pattern = r"^\d{4}-[a-z0-9-]+$"
    return bool(re.match(pattern, name.lower()))


def create_project(
    project_name: str,
    author: str = "",
    description: str = "",
    force: bool = False,
) -> Path:
    """
    Create a new project from the template.

    Parameters
    ----------
    project_name : str
        Name of the project (format: YYYY-description)
    author : str
        Author name
    description : str
        Project description
    force : bool
        Overwrite if project exists

    Returns
    -------
    Path
        Path to created project
    """
    # Validate name
    if not validate_project_name(project_name):
        print(f"Warning: Project name '{project_name}' doesn't follow YYYY-description format")
        print("Recommended format: 2024-my-project-name")

    # Paths
    template_dir = REPO_ROOT / "templates" / "project-template"
    projects_dir = REPO_ROOT / "projects"
    project_dir = projects_dir / project_name

    # Check if template exists
    if not template_dir.exists():
        print(f"Error: Template not found at {template_dir}")
        sys.exit(1)

    # Check if project already exists
    if project_dir.exists():
        if force:
            print(f"Removing existing project: {project_dir}")
            shutil.rmtree(project_dir)
        else:
            print(f"Error: Project already exists: {project_dir}")
            print("Use --force to overwrite")
            sys.exit(1)

    # Copy template
    print(f"Creating project: {project_name}")
    shutil.copytree(template_dir, project_dir)

    # Update README
    readme_path = project_dir / "README.md"
    if readme_path.exists():
        content = readme_path.read_text()

        # Replace placeholders
        replacements = {
            "[Project Title]": project_name.replace("-", " ").title(),
            "[Your Name]": author or "[Your Name]",
            "[YYYY-MM-DD]": datetime.now().strftime("%Y-%m-%d"),
            "[Planning | In Progress | Completed | Published]": "In Progress",
        }

        for old, new in replacements.items():
            content = content.replace(old, new)

        readme_path.write_text(content)

    # Create empty .gitkeep files in subdirectories
    for subdir in ["notebooks", "src", "results", "reports"]:
        gitkeep = project_dir / subdir / ".gitkeep"
        gitkeep.touch()

    print(f"\nProject created successfully!")
    print(f"Location: {project_dir}")
    print(f"\nNext steps:")
    print(f"  1. cd {project_dir}")
    print(f"  2. Edit README.md with your project details")
    print(f"  3. Start working in notebooks/ or src/")

    return project_dir


def main():
    parser = argparse.ArgumentParser(
        description="Create a new research project from template",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/create_new_project.py "2024-climate-analysis"
  python scripts/create_new_project.py "2024-deforestation-study" --author "Maria Silva"
  python scripts/create_new_project.py "2024-test" --force
        """,
    )

    parser.add_argument(
        "project_name",
        type=str,
        help="Project name (recommended format: YYYY-description)",
    )
    parser.add_argument(
        "--author",
        type=str,
        default="",
        help="Author name for README",
    )
    parser.add_argument(
        "--description",
        type=str,
        default="",
        help="Brief project description",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite if project already exists",
    )

    args = parser.parse_args()

    create_project(
        project_name=args.project_name,
        author=args.author,
        description=args.description,
        force=args.force,
    )


if __name__ == "__main__":
    main()
