# Web UI Customization Guide

This guide covers how to customize the Pipe Network Web UI for developers who want to modify or extend the default interface.

## Overview

The Web UI is designed to be modular and customizable. You can modify styles, add new components, or even create entirely new tabs while maintaining compatibility with the underlying system.

## Directory Structure

UI assets are located in the following directory:

```
src/ui/web/
├── css/
│   ├── main.css          # Main styles
│   └── themes/           # Theme variations
├── js/
│   ├── app.js            # Main application logic
│   ├── api.js            # API client
│   └── components/       # UI components
└── assets/               # Images and other assets
```

## Styling Customizations

### Basic Style Changes

The simplest customization is changing colors and styles in the CSS:

1. Create a custom CSS file in `src/ui/web/css/custom.css`
2. Import your file in `index.html` after the main CSS
3. Override the default styles

Example custom CSS:

```css
:root {
  --primary-color: #3498db;
  --secondary-color: #2ecc71;
  --text-color: #333333;
  --background-color: #f5f5f5;
}

.header {
  background-color: var(--primary-color);
  border-bottom: 2px solid var(--secondary-color);
}
```

### Creating a Theme

For more extensive styling changes, create a theme:

1. Create a new file in `src/ui/web/css/themes/` (e.g., `dark-theme.css`)
2. Include all your theme-specific overrides
3. Add a theme switcher to your custom UI

Example theme switcher:

```javascript
function applyTheme(themeName) {
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = `css/themes/${themeName}.css`;
  document.head.appendChild(link);
  localStorage.setItem('theme', themeName);
}

// Apply saved theme or default
const savedTheme = localStorage.getItem('theme') || 'default';
applyTheme(savedTheme);
```

## Adding Components

The UI uses a component-based architecture. To add a new component:

1. Create a new file in `src/ui/web/js/components/` (e.g., `custom-widget.js`)
2. Define your component using standard JS or the format of existing components
3. Import and mount your component in the appropriate section

Example component:

```javascript
// src/ui/web/js/components/custom-widget.js
class CustomWidget {
  constructor(container) {
    this.container = container;
    this.render();
  }

  render() {
    this.container.innerHTML = `
      <div class="widget custom-widget">
        <h3>Custom Widget</h3>
        <div class="widget-content">
          <p>This is a custom widget</p>
          <button id="customAction">Custom Action</button>
        </div>
      </div>
    `;
    
    document.getElementById('customAction').addEventListener('click', () => {
      this.performAction();
    });
  }

  performAction() {
    // Component logic here
    console.log('Custom action performed');
    // API call example
    apiClient.get('/api/custom-endpoint')
      .then(data => console.log(data));
  }
}

// Export the component
export default CustomWidget;
```

Then import and use it:

```javascript
// In your app.js or another entry point
import CustomWidget from './components/custom-widget.js';

// Mount it when needed
const widgetContainer = document.getElementById('widget-area');
const customWidget = new CustomWidget(widgetContainer);
```

## Adding a Custom Tab

To add an entirely new tab to the interface:

1. Create the tab component following the component pattern above
2. Add the tab to the navigation
3. Add the tab's content area to the main application

Example:

```javascript
// src/ui/web/js/components/custom-tab.js
class CustomTab {
  constructor() {
    this.addTabToNavigation();
    this.createContentArea();
  }

  addTabToNavigation() {
    const navBar = document.querySelector('.tab-navigation');
    const tabButton = document.createElement('button');
    tabButton.className = 'tab-button';
    tabButton.id = 'custom-tab-button';
    tabButton.textContent = 'Custom Tab';
    tabButton.addEventListener('click', () => this.activateTab());
    navBar.appendChild(tabButton);
  }

  createContentArea() {
    const mainContent = document.querySelector('.tab-content-container');
    const tabContent = document.createElement('div');
    tabContent.className = 'tab-content';
    tabContent.id = 'custom-tab-content';
    tabContent.style.display = 'none';
    tabContent.innerHTML = `
      <h2>Custom Tab</h2>
      <p>This is a custom tab with unique functionality.</p>
      <div id="custom-tab-widgets"></div>
    `;
    mainContent.appendChild(tabContent);
  }

  activateTab() {
    // Hide all other tabs
    document.querySelectorAll('.tab-content').forEach(tab => {
      tab.style.display = 'none';
    });
    document.querySelectorAll('.tab-button').forEach(button => {
      button.classList.remove('active');
    });
    
    // Show this tab
    document.getElementById('custom-tab-content').style.display = 'block';
    document.getElementById('custom-tab-button').classList.add('active');
    
    // Initialize tab content if needed
    this.initializeContent();
  }

  initializeContent() {
    // Load any data or initialize components specific to this tab
    const widgetsContainer = document.getElementById('custom-tab-widgets');
    // Add your custom widgets or content
  }
}

export default CustomTab;
```

## Extending the API

If your UI extensions need additional data, you can extend the API:

1. Create a new route file in `src/ui/server/routes/custom-api.js`
2. Define your endpoints
3. Import and use in the main server file

Example custom API:

```javascript
// src/ui/server/routes/custom-api.js
const express = require('express');
const router = express.Router();
const { executeCommand } = require('../services/command');

// Custom endpoint that uses the command execution service
router.get('/custom-data', async (req, res) => {
  try {
    const result = await executeCommand('your-custom-command');
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
```

Then in the main app.js:

```javascript
const customApiRoutes = require('./routes/custom-api');
app.use('/api/custom', customApiRoutes);
```

## Building and Deploying Customizations

After making your customizations:

1. Build the UI if you're using a build process:
   ```bash
   cd src/ui
   npm run build
   ```

2. Deploy your changes by copying the updated files to your Pipe Network installation, or if you're developing a distribution:
   ```bash
   ./scripts/package-ui.sh
   ```

3. Restart the UI server:
   ```bash
   pop --ui restart
   ```

## Best Practices

1. **Maintain Compatibility**: Ensure your changes don't break existing functionality
2. **Follow Design Patterns**: Stay consistent with the existing code structure
3. **Minimize Dependencies**: Avoid adding large external libraries
4. **Document Your Changes**: Add comments explaining your customizations
5. **Test Thoroughly**: Test across different browsers and device sizes
6. **Consider Performance**: Optimize for low-resource environments

## Debugging

The Web UI includes developer tools to help debug customizations:

1. Enable developer mode:
   ```bash
   pop --ui config --dev-mode=true
   ```

2. Access the debug console in the UI by pressing `Ctrl+Shift+D`

3. View detailed logs:
   ```bash
   pop --ui logs --level=debug
   ```

## Examples

Check the `examples/ui-customizations/` directory for sample customizations:

- `examples/ui-customizations/dark-theme/` - A complete dark theme implementation
- `examples/ui-customizations/network-map/` - A custom tab showing a network node map
- `examples/ui-customizations/system-monitor/` - Enhanced system monitoring widgets 