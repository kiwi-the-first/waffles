# Interaction Mode Settings

This quickshell bar now supports both hover and click interaction modes for the calendar and action center.

## Features

### Global Settings (`InteractionSettings`)
- **Global hover mode**: Controls default behavior for both calendar and action center
- **Individual overrides**: Can set calendar and action center modes independently
- **Default**: Hover mode enabled for both components

### Usage

#### In the Action Center
1. Open the action center (hover over or click the arrow button on the bar)
2. Find the "Interaction Mode" panel 
3. Click "Hover" for hover-based interactions
4. Click "Click" for click-based interactions

#### Programmatic Control
```qml
// Set global mode (affects both calendar and action center)
Root.InteractionSettings.setGlobalHoverMode(true);   // Enable hover mode
Root.InteractionSettings.setGlobalHoverMode(false);  // Enable click mode

// Set individual component modes
Root.InteractionSettings.setCalendarMode(true);      // Calendar hover mode
Root.InteractionSettings.setActionCenterMode(false); // Action center click mode
```

### Behavior

#### Hover Mode (Default)
- **Calendar**: Opens when hovering over clock, closes 200ms after mouse leaves
- **Action center**: Opens when hovering over arrow button, closes 200ms after mouse leaves
- **Benefits**: Quick access, no clicking required
- **Timer delay**: 200ms to prevent accidental closing when moving between elements

#### Click Mode  
- **Calendar**: Opens/closes when clicking the clock
- **Action center**: Opens/closes when clicking the arrow button
- **Benefits**: More deliberate control, won't open accidentally

### Technical Implementation

#### Components Updated
- `CalendarManager.qml` - Added hover functionality and timer management
- `ActionCenterManager.qml` - Added hover functionality and timer management  
- `Clock.qml` - Added hover handlers for calendar
- `ActionCenterButton.qml` - Added hover handlers for action center
- `CalendarWindow.qml` - Added HoverHandler to prevent premature closing
- `ActionCenterWindow.qml` - Added HoverHandler to prevent premature closing
- `InteractionSettings.qml` - Global settings manager (singleton)
- `InteractionModePanel.qml` - UI settings panel

#### Key Features
- **Singleton pattern**: Settings are shared across all components
- **Dynamic binding**: Mode changes take effect immediately
- **Timer coordination**: Prevents flicker and accidental closures
- **Boundary detection**: Only closes when mouse truly leaves component area
