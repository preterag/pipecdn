# Pipe PoP Binary Directory

This directory contains the Pipe PoP binary executable file.

## Contents

- `pipe-pop`: The main Pipe PoP node executable

## Notes

- The binary is automatically downloaded and updated by the setup and update scripts
- Do not modify the binary file manually
- Use the update script (`../update_binary.sh`) to update the binary to a newer version
- The binary should have executable permissions (set with `chmod +x pipe-pop`)

## Version Information

The current binary version can be checked with:

```bash
./pipe-pop --version
``` 