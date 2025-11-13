#!/bin/bash

# Nokia FastMile HA Integration - GitHub Setup Script
# This script will prepare and push your integration to GitHub

set -e

echo "=========================================="
echo "Nokia FastMile HA - GitHub Setup"
echo "=========================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git first."
    echo "Run: sudo apt-get install git"
    exit 1
fi

# Get GitHub username
echo "Enter your GitHub username:"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo "Error: GitHub username cannot be empty"
    exit 1
fi

# Get repository name
echo ""
echo "Enter repository name (default: nokia-fastmile-ha):"
read -r REPO_NAME
REPO_NAME=${REPO_NAME:-nokia-fastmile-ha}

echo ""
echo "Configuration:"
echo "  GitHub Username: $GITHUB_USERNAME"
echo "  Repository Name: $REPO_NAME"
echo "  Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "Is this correct? (yes/no)"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "Step 1: Updating repository URLs in files..."

# Update URLs in manifest.json
sed -i "s/yourusername/$GITHUB_USERNAME/g" custom_components/nokia_fastmile/manifest.json
sed -i "s/codeowners\": \[\"@[^\"]*\"/codeowners\": [\"@$GITHUB_USERNAME\"/g" custom_components/nokia_fastmile/manifest.json

# Update URLs in all markdown files
find . -type f -name "*.md" ! -name "README.md" -exec sed -i "s/yourusername/$GITHUB_USERNAME/g" {} +
find . -type f -name "*.md" ! -name "README.md" -exec sed -i "s/nokia-fastmile-ha/$REPO_NAME/g" {} +

# Rename README_INTEGRATION.md to README.md
if [ -f "README_INTEGRATION.md" ]; then
    echo "Step 2: Renaming README_INTEGRATION.md to README.md..."
    sed -i "s/yourusername/$GITHUB_USERNAME/g" README_INTEGRATION.md
    sed -i "s/nokia-fastmile-ha/$REPO_NAME/g" README_INTEGRATION.md
    mv README_INTEGRATION.md README.md
fi

# Update INFO.md
if [ -f "INFO.md" ]; then
    sed -i "s/yourusername/$GITHUB_USERNAME/g" INFO.md
    sed -i "s/nokia-fastmile-ha/$REPO_NAME/g" INFO.md
fi

echo "Step 3: Initializing git repository..."

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    git init
    echo "Git repository initialized."
else
    echo "Git repository already exists."
fi

# Configure git if needed
if [ -z "$(git config user.name)" ]; then
    echo ""
    echo "Git user not configured. Enter your name:"
    read -r GIT_NAME
    git config user.name "$GIT_NAME"
fi

if [ -z "$(git config user.email)" ]; then
    echo ""
    echo "Git email not configured. Enter your email:"
    read -r GIT_EMAIL
    git config user.email "$GIT_EMAIL"
fi

echo "Step 4: Adding files to git..."
git add .

echo "Step 5: Creating initial commit..."
git commit -m "Initial release v1.0.0

- Complete Home Assistant integration for Nokia FastMile 5G
- 17 sensors for comprehensive monitoring
- Device reboot button
- UI-based configuration flow
- HACS compatible
- Full documentation" || echo "Nothing to commit or already committed"

echo "Step 6: Setting up remote repository..."

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    echo "Remote 'origin' already exists. Updating URL..."
    git remote set-url origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
else
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Create the repository on GitHub:"
echo "   - Go to: https://github.com/new"
echo "   - Repository name: $REPO_NAME"
echo "   - Description: Home Assistant integration for Nokia FastMile 5G receivers"
echo "   - Make it PUBLIC (required for HACS)"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo "   - Click 'Create repository'"
echo ""
echo "2. Push to GitHub:"
echo "   cd /home/daniel/NokiaFastMile"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Create a release:"
echo "   - Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/releases/new"
echo "   - Tag version: v1.0.0"
echo "   - Release title: v1.0.0 - Initial Release"
echo "   - Copy description from CHANGELOG.md"
echo "   - Click 'Publish release'"
echo ""
echo "4. Install in Home Assistant:"
echo "   - Method 1 (HACS Custom Repository):"
echo "     HACS → Integrations → ⋮ → Custom repositories"
echo "     Add: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "     Category: Integration"
echo ""
echo "   - Method 2 (Manual):"
echo "     cp -r custom_components/nokia_fastmile /config/custom_components/"
echo ""
echo "Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "=========================================="
