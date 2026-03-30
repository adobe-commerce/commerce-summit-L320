#!/bin/bash

# Parse command line arguments
SKIP_PREREQS=false
for arg in "$@"; do
    case $arg in
        --skip-prereqs)
        SKIP_PREREQS=true
        shift
        ;;
    esac
done

# Check prerequisites
if [ "$SKIP_PREREQS" = false ]; then
    echo -e "\n*************************************************\n"
    echo -e "Checking prerequisites"

    # Check git installation
    echo -e "\nChecking git installation..."
    if ! command -v git &> /dev/null; then
        echo "ERROR: git is not installed. Please install git and try again."
        exit 1
    fi
    git --version

    # Check Node.js version (must be exactly 22)
    echo -e "\nChecking Node.js version..."
    if ! command -v node &> /dev/null; then
        echo "ERROR: Node.js is not installed. Please install Node.js 22."
        exit 1
    fi

    NODE_VERSION=$(node --version | sed 's/v//')
    NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1)
    REQUIRED_NODE_MAJOR="22"
    echo "Found Node.js version: v$NODE_VERSION"

    if [ "$NODE_MAJOR_VERSION" -ne "$REQUIRED_NODE_MAJOR" ]; then
        echo "ERROR: Node.js version must be any version of $REQUIRED_NODE_MAJOR. Found: v$NODE_VERSION"
        exit 1
    fi
    echo "Node.js version is correct"

    # Check npm version (should be 9 or higher)
    echo -e "\nChecking npm version..."
    if ! command -v npm &> /dev/null; then
        echo "ERROR: npm is not installed. Please install npm 9 or higher."
        exit 1
    fi

    NPM_VERSION=$(npm --version)
    NPM_MAJOR_VERSION=$(echo $NPM_VERSION | cut -d. -f1)
    REQUIRED_NPM_MAJOR="9"
    echo "Found npm version: $NPM_VERSION"

    if [ "$NPM_MAJOR_VERSION" -lt "$REQUIRED_NPM_MAJOR" ]; then
        echo "ERROR: npm version must be $REQUIRED_NPM_MAJOR or higher. Found: $NPM_VERSION"
        exit 1
    fi
    echo "npm version is sufficient"

    echo -e "\nAll prerequisites met!\n"
else
    echo -e "\n*************************************************\n"
    echo -e "Skipping prerequisite checks"
fi

# Install aio cli
echo -e "\n*************************************************\n"
echo -e "\nInstalling aio cli\n"
npm install -g @adobe/aio-cli

# Disable telemetry prompt
aio config set telemetry false --global

# Install aio commerce plugin
echo -e "\n*************************************************\n"
echo -e "\nInstalling aio commerce plugin\n"
aio plugins:install https://github.com/adobe-commerce/aio-cli-plugin-commerce

# Install aio runtime plugin
echo -e "\n*************************************************\n"
echo -e "\nInstalling aio runtime plugin\n"
aio plugins:install @adobe/aio-cli-plugin-runtime

# Install aio app dev plugin
echo -e "\n*************************************************\n"
echo -e "\nInstalling aio app dev plugin\n"
aio plugins:install @adobe/aio-cli-plugin-app-dev

echo "Installing Adobe AEM CLI..."
npm install -g @adobe/aem-cli

# Verify installation
if ! command -v aem &> /dev/null
then
  echo "Adobe AEM CLI installation failed. Please install manually."
  exit 1
fi

echo "Adobe AEM CLI installed successfully."

# aio config clear
echo -e "\n*************************************************\n"
echo -e "\nClearing aio config\n"
aio config clear --force

echo -e "\n*************************************************\n"
echo -e "\nSetup complete!\n"
echo -e "\n*************************************************\n"
