# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the Caelestia dotfiles configuration repository, specifically the hypr subdirectory containing Hyprland window manager configurations. The repository contains system configuration files for a complete Arch Linux desktop environment using Hyprland as the compositor.

## Key Architecture

### Directory Structure
- `hypr/` - Main Hyprland configurations split into modular files:
  - `hyprland.conf` - Main entry point that sources other configs
  - `hyprland/*.conf` - Modular configs (animations, colors, keybinds, etc.)
  - `scripts/` - Fish shell scripts for dynamic configuration and utilities
  - `scheme/` - Color scheme configurations
  - `templates/` - Templates for generating hyprlock configs dynamically

### Configuration Architecture
- Uses modular `.conf` files that are sourced from `hyprland.conf`
- Dynamic configuration via Fish shell scripts (e.g., `get-overrides.fish` for applying style overrides)
- Template-based generation for hyprlock screen locker configs
- User-specific overrides supported via `~/.config/caelestia/hypr-user.conf`

## Common Commands

### Installation
```bash
./install.fish [--noconfirm] [--spotify] [--vscode=codium|code] [--discord] [--zen]
```

### Hyprland Management
```bash
hyprctl reload                    # Reload Hyprland configuration
loginctl lock-session            # Lock screen (Super+L)
```

### Dynamic Configuration
```bash
~/.config/hypr/scripts/gen-hyprlock.fish    # Generate hyprlock config from templates
~/.config/hypr/scripts/monitor-config.fish  # Monitor configuration helper
```

### Key Shell Commands (used in keybinds)
```bash
caelestia workspace-action       # Workspace navigation/movement
caelestia toggle [specialws|sysmon|music|communication|todo]  # Toggle special workspaces
caelestia launcher              # Application launcher
caelestia clipboard             # Clipboard manager
caelestia record [-s|-r]        # Screen recording
```

## Important Technical Details

1. **Keybind System**: Uses submaps with a global submap as default. Super key triggers launcher with interrupt handling.

2. **Dynamic Generation**: `hyprlock.conf` is generated from templates based on monitor configuration and selected style.

3. **Integration Points**:
   - Fish shell for all scripting
   - Integration with `caelestia` CLI tool for workspace management and utilities
   - Uses `app2unit` for launching applications
   - Integrates with systemd for session management

4. **Configuration Loading Order**:
   1. Main `hyprland.conf`
   2. Modular configs from `hyprland/` directory
   3. Dynamic overrides via `get-overrides.fish`
   4. User overrides from `~/.config/caelestia/hypr-user.conf`

5. **Dependencies**: Requires `caelestia-meta` package which installs all necessary dependencies via yay/AUR.