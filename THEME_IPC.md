# Theme IPC Commands

The theme system can be controlled via IPC calls to the `theme` target.

## Available Commands

You can list all available IPC targets and functions using:
```bash
qs ipc show
```

### Set Theme

```bash
# Set to light theme
qs ipc call theme setTheme light

# Set to dark theme  
qs ipc call theme setTheme dark

# Set to auto theme (follows system)
qs ipc call theme setTheme auto
```

### Toggle Theme

```bash
# Toggle between light and dark themes
qs ipc call theme toggleTheme
```

### Get Current Theme

```bash
# Get the current theme setting
qs ipc call theme getTheme
```

## Usage Examples

### Keyboard Shortcuts

You can bind these to keyboard shortcuts in your desktop environment:

```bash
# Toggle theme with Super+T
qs ipc call theme toggleTheme

# Set to light mode with Super+Shift+L
qs ipc call theme setTheme light

# Set to dark mode with Super+Shift+D
qs ipc call theme setTheme dark
```

### Script Integration

```bash
#!/bin/bash
current_theme=$(qs ipc call theme getTheme)
if [ "$current_theme" = "light" ]; then
    qs ipc call theme setTheme dark
    echo "Switched to dark theme"
else
    qs ipc call theme setTheme light
    echo "Switched to light theme"
fi
```

### Time-based Theme Switching

```bash
# Add to crontab for automatic day/night themes
# Switch to light at 7 AM
0 7 * * * qs ipc call theme setTheme light

# Switch to dark at 7 PM  
0 19 * * * qs ipc call theme setTheme dark
```
