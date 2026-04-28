#!/bin/bash
# Script to update Jujutsu (jj) zsh completions including personal aliases

set -euo pipefail

COMPLETIONS_DIR="${HOME}/.config/zsh/completions"
JJ_CONFIG="${HOME}/.config/jj/config.toml"

# Check that jj is available
if ! command -v jj &> /dev/null; then
    echo "Error: jj is not installed or not in PATH" >&2
    exit 1
fi

# Create directory if needed
mkdir -p "$COMPLETIONS_DIR"

# Generate native jj completions
jj util completion zsh > "${COMPLETIONS_DIR}/_jj"
echo "✓ Native jj completions updated in ${COMPLETIONS_DIR}/_jj"

# Extract personal aliases from ~/.config/jj/config.toml
aliases=()
if [[ -f "$JJ_CONFIG" ]]; then
    in_aliases_section=false
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check if we're entering the [aliases] section
        if [[ "$line" =~ ^\[aliases\] ]]; then
            in_aliases_section=true
            continue
        fi
        
        # Check if we're leaving the [aliases] section (new section starts)
        if [[ "$line" =~ ^\[.*\] ]] && [[ "$in_aliases_section" == true ]]; then
            break
        fi
        
        # If we're in the aliases section and line contains an alias definition
        if [[ "$in_aliases_section" == true ]] && [[ "$line" =~ ^[a-zA-Z0-9_-]+[[:space:]]*= ]]; then
            # Extract the alias name (everything before the first =)
            alias_name=$(echo "$line" | sed 's/[[:space:]]*=.*//' | tr -d ' ')
            if [[ -n "$alias_name" ]]; then
                aliases+=("$alias_name")
            fi
        fi
    done < "$JJ_CONFIG"
fi

# Inject aliases into _jj file if any were found
if [[ ${#aliases[@]} -gt 0 ]]; then
    # Find the line number of the _jj_commands function
    # and the line number where the commands array ends (the closing parenthesis)
    
    # First, find the line where _jj_commands() starts
    jj_commands_start=$(grep -n "^_jj_commands()" "${COMPLETIONS_DIR}/_jj" | head -1 | cut -d':' -f1)
    
    if [[ -n "$jj_commands_start" ]]; then
        # Find the line where the commands array ends in _jj_commands
        # We look for the first line starting with "    )" after _jj_commands start
        # but before the next function definition
        
        # Get the content from _jj_commands start to find the closing paren
        tail -n +"$jj_commands_start" "${COMPLETIONS_DIR}/_jj" > /tmp/jj_commands_section.txt
        
        # Find the line number (relative) of the closing parenthesis "    )"
        closing_paren_relative=$(grep -n "^    )" /tmp/jj_commands_section.txt | head -1 | cut -d':' -f1)
        
        if [[ -n "$closing_paren_relative" ]]; then
            # Calculate absolute line number
            closing_paren_line=$((jj_commands_start + closing_paren_relative - 1))
            
            # Create the aliases text to insert
            aliases_text=""
            for alias_name in "${aliases[@]}"; do
                aliases_text+="'${alias_name}:Custom alias' \\\\\n"
            done
            
            # Use sed to insert the aliases before the closing parenthesis
            sed -i "${closing_paren_line}i\\
${aliases_text}" "${COMPLETIONS_DIR}/_jj"
            
            echo "✓ Personal aliases injected into _jj: ${aliases[*]}"
        else
            echo "Warning: Could not find closing parenthesis in _jj_commands" >&2
        fi
        
        rm -f /tmp/jj_commands_section.txt
    else
        echo "Warning: Could not find _jj_commands function" >&2
    fi
else
    echo "ℹ No personal aliases found in ${JJ_CONFIG}"
fi

# Clean up any old _jj_aliases file
rm -f "${COMPLETIONS_DIR}/_jj_aliases"

echo ""
echo "Restart your terminal or run 'exec zsh' to apply changes"
