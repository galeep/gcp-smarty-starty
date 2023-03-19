#!/bin/bash

# Script Name: gcp-smarty-starty.sh
#
# Description:
# This script automates the process of setting up a new Google Cloud Platform (GCP) project.
# It simplifies the tedious and repetitive task of creating, configuring, and linking
# billing accounts to GCP projects. The script generates a project ID, creates the project,
# sets the active project, and links the billing account, all with minimal user input.
# It is designed to save time and effort for users who frequently create and manage GCP projects,
# particularly those who have multiple side projects or experiments.
#
# Features:
# - User-friendly and straightforward to use
# - Generates a unique project ID with a customizable prefix
# - Creates and configures the project with the given billing account
# - Provides an option to perform a dry run without actually creating the project
# - Supports non-interactive mode for automation purposes
# - Allows the use of a custom dictionary file or a fallback dictionary for project ID generation
#
# Usage:
# Run the script with the desired options and follow the prompts to create a new GCP project.
# For a detailed explanation of the available options, run the script with the '--help' flag.

# Define default values for script options and variables

# DEFAULT_PREFIX: The default prefix to use for the generated project ID if none is provided by the user.
DEFAULT_PREFIX="myproject"

# DRY_RUN: If set to 1, the script performs a dry run without actually creating the project and linking the billing account.
DRY_RUN=0

# NON_INTERACTIVE: If set to 1, the script runs in non-interactive mode and does not prompt the user for any input. 
# Required information must be provided through command line options.
NON_INTERACTIVE=0

# QUICK_MODE: If set to 1, the script uses a fallback dictionary for word generation in project ID instead of the system's dictionary file.
QUICK_MODE=0

# TEMP_FILE_CREATED: Indicates if a temporary file was created by the script.
TEMP_FILE_CREATED=

# Define the fallback dictionary content
DICT_FILE_CONTENT="apple
banana
cherry
dog
elephant
fish
goat
house
ice
jacket
kite
lemon
mouse
nose
orange
pig
queen
rabbit
shoe
turtle
umbrella
violin
walrus
xylophone
yacht
zebra
"

# Define a cleanup function to handle signals and remove temporary files
cleanup() {
    local error_msg="$1"
    if [ -n "$TEMP_FILE_CREATED" ]; then
        rm "$DICT_TMFILE"
    fi
    if [ -n "$error_msg" ]; then
        echo "Error: $error_msg"
    fi
    exit 1
}

# Define a function to print help text for the script
print_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  -p, --prefix          Set a prefix for the project ID.
  -u, --user            Set prefix format to 'user-word'.
  -h, --help            Display this help text.
  -b, --billing         Set the default billing account ID.
  -n, --dry-run         Perform a dry run without creating the project.
  -w, --wordfile        Use a custom dictionary file for word generation.
  -q, --quick           Use the fallback dictionary for word generation.
  -y, --non-interactive Run non-interactively (fails if insufficient info is provided).
EOF
}

# Define a function to check the format of the billing account ID
check_billing_account_id_format() {
    if [[ ! "$BILLING_ACCOUNT_ID" =~ ^[A-Z0-9]{6}-[A-Z0-9]{6}-[A-Z0-9]{6}$ ]]; then
        echo "Unsupported billing account ID format: $BILLING_ACCOUNT_ID"
        echo "Billing account IDs typically have the format CCCCCC-CCCCCC-CCCCCC, "
        echo "where each C is an uppercase letter or a number."
        echo " "
        echo "Double-check the billing account ID, and try entering it manually "
        echo "if you are certain it is correct."
        exit 1
    fi
}

# Define a function to parse and execute the script options provided by the user
parse_and_execute_options() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -p|--prefix)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    echo "Error: --prefix option requires a value"
                    exit 1
                fi
                PREFIX="$2"
                shift 2
                ;;
            -u|--user)
                PREFIX_FORMAT="user-word"
                shift
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            -b|--billing)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    echo "Error: --billing option requires a value"
                    exit 1
                fi
                BILLING_ACCOUNT_ID="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=1
                shift
                ;;
            -w|--wordfile)
                if [ -z "$2" ] || [[ "$2" == -* ]]; then
                    echo "Error: --wordfile option requires a value"
                    exit 1
                fi
                CUSTOM_WORDFILE="$2"
                shift 2
                ;;
            -q|--quick)
                QUICK_MODE=1
                shift
                ;;
            -y|--non-interactive)
                NON_INTERACTIVE=1
                shift
                ;;
            --)
                shift
                break
                ;;
            -[!-]*)
                optarg="$1"
                shift
                for ((i = 1; i < ${#optarg}; i++)); do
                    set -- "-${optarg:$i:1}" "$@"
                done
                ;;
            *)
                break
                ;;
        esac
    done
}

# Execute the parse_and_execute_options function with provided arguments
parse_and_execute_options "$@"  

if [ -n "$BILLING_ACCOUNT_ID" ]; then
    check_billing_account_id_format
fi

# Define a function to check if the gcloud command is available
check_gcloud() {
    if ! command -v gcloud &> /dev/null; then
        echo "Google Cloud SDK not found. Downloading and installing it now..."
        curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk.tar.gz
        tar zxvf google-cloud-sdk.tar.gz
        ./google-cloud-sdk/install.sh
        source ./google-cloud-sdk/path.bash.inc
        echo "Google Cloud SDK installed successfully."
    fi
}

# Define a function to check if the user is authenticated with gcloud
check_authentication() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep '@'; then
        echo "No active account found. Please authenticate using 'gcloud auth login'."
        exit 1
    fi
}

# Define a function to confirm the active account before proceeding
confirm_active_account() {
    ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
    if [ "$NON_INTERACTIVE" -eq 0 ]; then
        read -p "You are authenticated with '$ACTIVE_ACCOUNT'. Do you want to continue? (y/n): " CONTINUE
    else
        CONTINUE="y"
    fi
    CONTINUE=$(echo "$CONTINUE" | tr '[:upper:]' '[:lower:]')
    if [[ "$CONTINUE" != "y" ]]; then
        echo "Please authenticate with the desired account using 'gcloud auth login'."
        exit 1
    fi
}

# Define a function to check the format of the project ID
check_project_id_format() {
    if [[ ! "$PROJECT_ID" =~ ^[a-z][a-z0-9-]{4,28}[a-z0-9]$ ]]; then
        echo "Invalid project ID format: $PROJECT_ID"
        exit 1
    fi
}

# Function to determine the dictionary file to use based on user options
# (note: not all mktemp(1) support --mode, hence explicit chmod(1)
determine_dictionary_file() {
    DICT_TMFILE=$(mktemp)
    TEMP_FILE_CREATED=1

    # Set file permissions
    chmod 0700 "$DICT_TMFILE"

    # Set trap for signals and call cleanup function upon receiving them
    trap 'cleanup "Script terminated by user"' SIGINT SIGTERM

    if [ -n "$CUSTOM_WORDFILE" ]; then 
        cat  "$CUSTOM_WORDFILE" > "$DICT_TMFILE"
    elif [ "$QUICK_MODE" -eq 1 ]; then
        echo "$DICT_FILE_CONTENT" > "$DICT_TMFILE"
    elif [ -f "/usr/share/dict/words" ]; then
        cat "/usr/share/dict/words" > "$DICT_TMFILE"
    else
        # fallback - use DICT_FILE_CONTENT
        echo "$DICT_FILE_CONTENT" > "$DICT_TMFILE"
    fi
}

# Function to generate the project ID based on the provided prefix and dictionary file
generate_project_id() {
    # Set default prefix
    if [ -z "$PREFIX" ]; then
        if [ "$PREFIX_FORMAT" == "user-word" ]; then
            WORD=$(grep -E '^[a-z]{1,6}$' "$DICT_TMFILE" | awk -v seed="$RANDOM" 'BEGIN{srand(seed);} {print rand(), $0}' | sort -n | cut -d ' ' -f2- | head -n 1)
            DEFAULT_PREFIX="${USER}-${WORD}"
        else
            WORDS=$(grep -E '^[a-z]{1,6}$' "$DICT_TMFILE" | awk -v seed="$RANDOM" 'BEGIN{srand(seed);} {print rand(), $0}' | sort -n | cut -d ' ' -f2- | head -n 2)
            DEFAULT_PREFIX=$(echo "$WORDS" | tr '\n' '-')
            DEFAULT_PREFIX=${DEFAULT_PREFIX%?}
        fi
        PREFIX="$DEFAULT_PREFIX"
    fi

    PROJECT_ID="${PREFIX}-$(openssl rand -hex 3)"
    check_project_id_format
}

# Function to retrieve the list of billing accounts and return the parsed output
get_billing_accounts() {
    gcloud beta billing accounts list --format="value(displayName, name)"
}

# Function to handle user input prompts for various settings
prompt_user_input() {
    if [ -z "$PREFIX" ] && [ $NON_INTERACTIVE -eq 0 ]; then
        read -p "Enter a prefix for the project ID (default: $DEFAULT_PREFIX): " USER_PREFIX
        PREFIX=${USER_PREFIX:-$DEFAULT_PREFIX}
    fi

    if [ -z "$BILLING_ACCOUNT_ID" ]; then
        if [ $NON_INTERACTIVE -eq 0 ]; then
            echo "Available billing accounts:"
            echo "$(get_billing_accounts)"
            read -p "Enter the billing account ID to use: " BILLING_ACCOUNT_ID
            check_billing_account_id_format
        else
            echo "Billing account ID is required when running in non-interactive mode."
            exit 1
        fi
    fi
}

# Function to create the project using the generated project ID and configure the billing account
create_and_configure_project() {
    if [ $DRY_RUN -eq 0 ]; then
        echo "Creating project with ID: $PROJECT_ID..."
        if gcloud projects create "$PROJECT_ID"; then
            echo "Project created successfully."
        else
            echo "Error: Project creation failed."
            exit 1 
        fi
    
        echo "Setting the active project to $PROJECT_ID..."
        if gcloud config set project "$PROJECT_ID"; then
            echo "Active project set successfully."
        else
            echo "Error: Failed to set the active project."
            exit 1 
        fi 

        echo "Linking billing account for $PROJECT_ID..."
        if gcloud beta billing projects link "$PROJECT_ID" --billing-account="$BILLING_ACCOUNT_ID"; then
            echo "Billing linked successfully for $PROJECT_ID 🔗 $BILLING_ACCOUNT_ID"
        else
            echo "Error: Failed to link billing account."
            exit 1
        fi
    else
        echo "Dry run: A project with the following ID would be created:"
        echo "  $PROJECT_ID"
        echo "Would have linked billing for"
        echo "$PROJECT_ID 🔗 $BILLING_ACCOUNT_ID"
        echo "Dry run completed. Project not created. Billing not linked."
    fi
}

# Execute the functions to check gcloud command, authentication, and confirm active account
check_gcloud
check_authentication
confirm_active_account

# Determine the dictionary file to use based on user options
determine_dictionary_file

# Generate the project ID
generate_project_id

# Prompt the user for input if necessary
prompt_user_input

# Display the generated project ID
echo "Generated Project ID: $PROJECT_ID"

# Create and configure the project
create_and_configure_project

# Remove the temporary dictionary file if it was created
if [ -n "$TEMP_FILE_CREATED" ]; then
    rm "$DICT_TMFILE"
fi
