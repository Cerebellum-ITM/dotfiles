# Available Commands

This document lists the available commands and their usage.

## Command Options
-   ## Command Options

-  ### **Tools**: The command has a number of options
    - Commands: `< --tools >` or `< -t >`
    - Usage: 
        - If the subcommand ChangeLog: Create a CHANGELOG.md file in the folder provided you have a 
        docker-compose file The rest of the operation is in `_create_a_changelog`
        - Example: 
          ```bash 
          if [[ $cmd_options == *'ChangeLog'* ]]; then
              _create_a_changelog
          fi
          ```

-   ### **Search for the URL of a port**: 
    - **Description**: Search for the URL associated with a specific Odoo port.
    - **Flags**: 
      - `< --search-odoo-port >` or `< -p >`
    - **Usage**: 
      - Use `-p < port >` to specify the port.
      - Example: `odoo -p 8069`

-   ### **Print the Caddyfile**:
    - **Description**: Print the contents of the Caddyfile.
    - **Flags**: 
      - `< --show-CaddyFile >` or `< -sh >`

-   ### **Open the Caddyfile in VSCode**:
    - **Description**: Open the Caddyfile for editing in Visual Studio Code.
    - **Flags**: 
      - `< --edit-CaddyFile >` or `< -e >`
    - **Usage**: 
      - Use `-c` to open the Caddyfile in VSCode