/**
 * main.js - Core JavaScript functionality for Pipe Network PoP Web UI
 */

// API Service - Handles all API requests
const ApiService = {
    // Base API endpoint
    baseUrl: '/api',
    
    // Helper method for making API requests
    async request(endpoint, method = 'GET', data = null) {
        const url = `${this.baseUrl}${endpoint}`;
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json'
            }
        };
        
        if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
            options.body = JSON.stringify(data);
        }
        
        try {
            const response = await fetch(url, options);
            
            if (!response.ok) {
                throw new Error(`API request failed: ${response.status} ${response.statusText}`);
            }
            
            return await response.json();
        } catch (error) {
            console.error(`Error in ${method} ${endpoint}:`, error);
            throw error;
        }
    },
    
    // Node status API methods
    async getNodeStatus() {
        return this.request('/status');
    },
    
    async startNode() {
        return this.request('/node/start', 'POST');
    },
    
    async stopNode() {
        return this.request('/node/stop', 'POST');
    },
    
    async restartNode() {
        return this.request('/node/restart', 'POST');
    },
    
    // Configuration API methods
    async getConfig() {
        return this.request('/config');
    },
    
    async updateConfig(config) {
        return this.request('/config', 'POST', config);
    },
    
    // Logs API methods
    async getLogs(limit = 100) {
        return this.request(`/logs?limit=${limit}`);
    }
};

// Dashboard Controller - Handles dashboard UI logic
const DashboardController = {
    // Elements
    elements: {
        nodeStatus: document.getElementById('node-status'),
        startBtn: document.getElementById('start-node'),
        stopBtn: document.getElementById('stop-node'),
        restartBtn: document.getElementById('restart-node'),
        statusCards: document.querySelectorAll('.status-card'),
        logsContainer: document.getElementById('logs-container')
    },
    
    // Initialize dashboard
    init() {
        // Check if we're on the dashboard page
        if (!this.elements.nodeStatus) return;
        
        // Set up event listeners
        this.setupEventListeners();
        
        // Initial data load
        this.loadDashboardData();
        
        // Set up auto-refresh (every 10 seconds)
        this.setupAutoRefresh();
    },
    
    // Set up event listeners
    setupEventListeners() {
        // Node control buttons
        if (this.elements.startBtn) {
            this.elements.startBtn.addEventListener('click', async () => {
                try {
                    await ApiService.startNode();
                    this.showNotification('Node started successfully', 'success');
                    this.loadDashboardData();
                } catch (error) {
                    this.showNotification('Failed to start node', 'error');
                }
            });
        }
        
        if (this.elements.stopBtn) {
            this.elements.stopBtn.addEventListener('click', async () => {
                try {
                    await ApiService.stopNode();
                    this.showNotification('Node stopped successfully', 'success');
                    this.loadDashboardData();
                } catch (error) {
                    this.showNotification('Failed to stop node', 'error');
                }
            });
        }
        
        if (this.elements.restartBtn) {
            this.elements.restartBtn.addEventListener('click', async () => {
                try {
                    await ApiService.restartNode();
                    this.showNotification('Node restarted successfully', 'success');
                    this.loadDashboardData();
                } catch (error) {
                    this.showNotification('Failed to restart node', 'error');
                }
            });
        }
    },
    
    // Load dashboard data
    async loadDashboardData() {
        try {
            const statusData = await ApiService.getNodeStatus();
            this.updateNodeStatus(statusData);
            
            // Load logs if logs container exists
            if (this.elements.logsContainer) {
                const logsData = await ApiService.getLogs();
                this.updateLogs(logsData);
            }
        } catch (error) {
            this.showNotification('Failed to load dashboard data', 'error');
        }
    },
    
    // Update node status display
    updateNodeStatus(data) {
        if (!this.elements.nodeStatus) return;
        
        const isRunning = data.data.node_status === 'running';
        
        // Update status indicator
        this.elements.nodeStatus.textContent = isRunning ? 'Running' : 'Stopped';
        this.elements.nodeStatus.className = isRunning ? 'status-value status-running' : 'status-value status-stopped';
        
        // Update control buttons
        if (this.elements.startBtn) {
            this.elements.startBtn.disabled = isRunning;
        }
        
        if (this.elements.stopBtn) {
            this.elements.stopBtn.disabled = !isRunning;
        }
        
        if (this.elements.restartBtn) {
            this.elements.restartBtn.disabled = !isRunning;
        }
    },
    
    // Update logs display
    updateLogs(data) {
        if (!this.elements.logsContainer) return;
        
        const logs = data.data.logs;
        let logsHtml = '';
        
        logs.forEach(log => {
            // Determine log level for styling
            let logClass = 'log-info';
            if (log.includes('[ERROR]')) {
                logClass = 'log-error';
            } else if (log.includes('[WARN]')) {
                logClass = 'log-warning';
            } else if (log.includes('[DEBUG]')) {
                logClass = 'log-debug';
            }
            
            logsHtml += `<div class="log-entry ${logClass}">${log}</div>`;
        });
        
        this.elements.logsContainer.innerHTML = logsHtml;
        
        // Scroll to bottom
        this.elements.logsContainer.scrollTop = this.elements.logsContainer.scrollHeight;
    },
    
    // Show notification
    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Add to DOM
        document.body.appendChild(notification);
        
        // Display notification with animation
        setTimeout(() => {
            notification.classList.add('show');
        }, 10);
        
        // Remove after 3 seconds
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => {
                document.body.removeChild(notification);
            }, 300);
        }, 3000);
    },
    
    // Setup auto-refresh
    setupAutoRefresh() {
        setInterval(() => {
            this.loadDashboardData();
        }, 10000); // Refresh every 10 seconds
    }
};

// Config Controller - Handles configuration UI logic
const ConfigController = {
    // Elements
    elements: {
        configForm: document.getElementById('config-form'),
        saveConfigBtn: document.getElementById('save-config')
    },
    
    // Initialize
    init() {
        // Check if we're on the config page
        if (!this.elements.configForm) return;
        
        // Load current config
        this.loadConfig();
        
        // Set up event listeners
        this.setupEventListeners();
    },
    
    // Load configuration
    async loadConfig() {
        try {
            const configData = await ApiService.getConfig();
            this.populateConfigForm(configData.data.config);
        } catch (error) {
            DashboardController.showNotification('Failed to load configuration', 'error');
        }
    },
    
    // Populate the config form
    populateConfigForm(config) {
        // Parse the configuration string
        // Example implementation - would need to be updated based on actual config format
        const configLines = config.split('\n');
        
        configLines.forEach(line => {
            if (line.includes('=')) {
                const [key, value] = line.split('=').map(part => part.trim());
                const inputEl = document.getElementById(`config-${key}`);
                
                if (inputEl) {
                    if (inputEl.type === 'checkbox') {
                        inputEl.checked = value.toLowerCase() === 'true';
                    } else {
                        inputEl.value = value;
                    }
                }
            }
        });
    },
    
    // Set up event listeners
    setupEventListeners() {
        if (this.elements.saveConfigBtn) {
            this.elements.saveConfigBtn.addEventListener('click', async (e) => {
                e.preventDefault();
                
                try {
                    const configData = this.getConfigFromForm();
                    await ApiService.updateConfig(configData);
                    DashboardController.showNotification('Configuration saved successfully', 'success');
                } catch (error) {
                    DashboardController.showNotification('Failed to save configuration', 'error');
                }
            });
        }
    },
    
    // Get configuration data from form
    getConfigFromForm() {
        const formData = new FormData(this.elements.configForm);
        const config = {};
        
        for (const [key, value] of formData.entries()) {
            config[key] = value;
        }
        
        return config;
    }
};

// Theme controller for handling dark/light mode
const ThemeController = {
    init() {
        const themeToggle = document.getElementById('theme-toggle');
        
        if (themeToggle) {
            // Check for saved theme preference or respect OS preference
            const savedTheme = localStorage.getItem('theme');
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            
            if (savedTheme === 'dark' || (!savedTheme && prefersDark)) {
                document.body.classList.add('dark-theme');
                themeToggle.checked = true;
            }
            
            // Set up event listener for theme toggle
            themeToggle.addEventListener('change', () => {
                if (themeToggle.checked) {
                    document.body.classList.add('dark-theme');
                    localStorage.setItem('theme', 'dark');
                } else {
                    document.body.classList.remove('dark-theme');
                    localStorage.setItem('theme', 'light');
                }
            });
        }
    }
};

// Navigation controller
const NavController = {
    init() {
        const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
        const mobileMenu = document.getElementById('mobile-menu');
        
        if (mobileMenuToggle && mobileMenu) {
            mobileMenuToggle.addEventListener('click', () => {
                mobileMenu.classList.toggle('open');
            });
        }
        
        // Highlight current page in navigation
        this.highlightCurrentPage();
    },
    
    highlightCurrentPage() {
        const currentPath = window.location.pathname;
        const navLinks = document.querySelectorAll('.nav-item');
        
        navLinks.forEach(link => {
            if (link.getAttribute('href') === currentPath) {
                link.classList.add('active');
            }
        });
    }
};

// Initialize all controllers when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    NavController.init();
    ThemeController.init();
    DashboardController.init();
    ConfigController.init();
    
    // Initialize tooltips if any
    const tooltips = document.querySelectorAll('[data-tooltip]');
    tooltips.forEach(tooltip => {
        tooltip.addEventListener('mouseenter', (e) => {
            const tooltipText = e.target.getAttribute('data-tooltip');
            const tooltipEl = document.createElement('div');
            tooltipEl.className = 'tooltip';
            tooltipEl.textContent = tooltipText;
            document.body.appendChild(tooltipEl);
            
            const rect = e.target.getBoundingClientRect();
            tooltipEl.style.top = `${rect.bottom + 10}px`;
            tooltipEl.style.left = `${rect.left + (rect.width / 2) - (tooltipEl.offsetWidth / 2)}px`;
            
            e.target.addEventListener('mouseleave', () => {
                document.body.removeChild(tooltipEl);
            }, { once: true });
        });
    });
}); 