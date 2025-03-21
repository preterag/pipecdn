/**
 * Web UI Server for Pipe Network PoP Node Management Tools
 * 
 * This server provides a web interface for managing Pipe Network nodes,
 * including an installation wizard for initial setup.
 */

const express = require('express');
const path = require('path');
const fs = require('fs');
const { spawn, exec } = require('child_process');
const app = express();
const port = process.argv.includes('--port') 
    ? parseInt(process.argv[process.argv.indexOf('--port') + 1]) 
    : 8585;

// Serve static files from the web directory
const webRoot = path.join(__dirname, '..', 'web');
app.use(express.static(webRoot));
app.use(express.json());

// Configuration
const dataDir = process.env.HOME + '/.local/share/pipe-pop';
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
}

// Wizard token verification middleware
const verifyWizardToken = (req, res, next) => {
    const tokenFile = path.join(dataDir, 'wizard-token.tmp');
    if (!fs.existsSync(tokenFile)) {
        return res.status(401).json({ error: 'Unauthorized: No active wizard session' });
    }
    
    const storedToken = fs.readFileSync(tokenFile, 'utf8').trim();
    const requestToken = req.query.token || req.body.token;
    
    if (requestToken !== storedToken) {
        return res.status(401).json({ error: 'Unauthorized: Invalid token' });
    }
    
    next();
};

// Helper function for executing shell commands
const executeCommand = (command, args = []) => {
    return new Promise((resolve, reject) => {
        const cmd = spawn(command, args);
        let stdout = '';
        let stderr = '';
        
        cmd.stdout.on('data', (data) => {
            stdout += data.toString();
        });
        
        cmd.stderr.on('data', (data) => {
            stderr += data.toString();
        });
        
        cmd.on('close', (code) => {
            if (code === 0) {
                resolve({ stdout, stderr });
            } else {
                reject({ code, stdout, stderr });
            }
        });
    });
};

// Routes for the wizard
app.get('/wizard', (req, res) => {
    res.sendFile(path.join(webRoot, 'wizard', 'index.html'));
});

// API Routes
const apiRouter = express.Router();

// System Status
apiRouter.get('/status', async (req, res) => {
    try {
        const result = await executeCommand('tools/pop', ['--status']);
        res.json({ 
            status: 'success',
            data: {
                output: result.stdout.trim(),
                node_status: result.stdout.includes('running') ? 'running' : 'stopped'
            }
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to get node status',
            error: error.stderr 
        });
    }
});

// Node Management
apiRouter.post('/node/start', async (req, res) => {
    try {
        const result = await executeCommand('tools/pop', ['--start']);
        res.json({ 
            status: 'success',
            message: 'Node started successfully',
            data: { output: result.stdout.trim() }
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to start node',
            error: error.stderr 
        });
    }
});

apiRouter.post('/node/stop', async (req, res) => {
    try {
        const result = await executeCommand('tools/pop', ['--stop']);
        res.json({ 
            status: 'success',
            message: 'Node stopped successfully',
            data: { output: result.stdout.trim() }
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to stop node',
            error: error.stderr 
        });
    }
});

apiRouter.post('/node/restart', async (req, res) => {
    try {
        const result = await executeCommand('tools/pop', ['--restart']);
        res.json({ 
            status: 'success',
            message: 'Node restarted successfully',
            data: { output: result.stdout.trim() }
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to restart node',
            error: error.stderr 
        });
    }
});

// Configuration
apiRouter.get('/config', async (req, res) => {
    try {
        const result = await executeCommand('tools/pop', ['--config', 'show']);
        res.json({ 
            status: 'success',
            data: { 
                config: result.stdout.trim(),
                // TODO: Parse config into JSON structure
            }
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to get configuration',
            error: error.stderr 
        });
    }
});

apiRouter.post('/config', async (req, res) => {
    // TODO: Implement configuration update
    res.status(501).json({ status: 'error', message: 'Not implemented yet' });
});

// Logs
apiRouter.get('/logs', async (req, res) => {
    try {
        const limit = req.query.limit || 100;
        const result = await executeCommand('tools/pop', ['--logs', limit.toString()]);
        res.json({ 
            status: 'success',
            data: { logs: result.stdout.trim().split('\n') }
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to get logs',
            error: error.stderr 
        });
    }
});

// Wizard API endpoints
const wizardRouter = express.Router();

// Get wizard status
wizardRouter.get('/status', verifyWizardToken, (req, res) => {
    // Read wizard progress from file or create default
    const wizardStatusFile = path.join(dataDir, 'wizard-status.json');
    let wizardStatus;
    
    if (fs.existsSync(wizardStatusFile)) {
        try {
            wizardStatus = JSON.parse(fs.readFileSync(wizardStatusFile, 'utf8'));
        } catch (error) {
            wizardStatus = {
                active: true,
                current_step: 'welcome',
                completed_steps: [],
                remaining_steps: ['welcome', 'system_check', 'configuration', 'installation', 'network_setup', 'complete'],
                progress_percent: 0
            };
        }
    } else {
        wizardStatus = {
            active: true,
            current_step: 'welcome',
            completed_steps: [],
            remaining_steps: ['welcome', 'system_check', 'configuration', 'installation', 'network_setup', 'complete'],
            progress_percent: 0
        };
        fs.writeFileSync(wizardStatusFile, JSON.stringify(wizardStatus, null, 2));
    }
    
    res.json(wizardStatus);
});

// Update wizard step
wizardRouter.post('/step', verifyWizardToken, (req, res) => {
    const { step, data } = req.body;
    if (!step) {
        return res.status(400).json({ error: 'Step parameter is required' });
    }
    
    // Read current wizard status
    const wizardStatusFile = path.join(dataDir, 'wizard-status.json');
    let wizardStatus;
    
    if (fs.existsSync(wizardStatusFile)) {
        try {
            wizardStatus = JSON.parse(fs.readFileSync(wizardStatusFile, 'utf8'));
        } catch (error) {
            return res.status(500).json({ error: 'Failed to read wizard status' });
        }
    } else {
        return res.status(404).json({ error: 'Wizard status not found' });
    }
    
    // Update the status
    const allSteps = ['welcome', 'system_check', 'configuration', 'installation', 'network_setup', 'complete'];
    const stepIndex = allSteps.indexOf(step);
    const nextStep = allSteps[stepIndex + 1] || 'complete';
    
    if (stepIndex === -1) {
        return res.status(400).json({ error: 'Invalid step name' });
    }
    
    // Add current step to completed steps if not already there
    if (!wizardStatus.completed_steps.includes(step)) {
        wizardStatus.completed_steps.push(step);
    }
    
    // Update remaining steps
    wizardStatus.remaining_steps = allSteps.slice(stepIndex + 1);
    
    // Set current step to next step
    wizardStatus.current_step = nextStep;
    
    // Calculate progress percentage
    wizardStatus.progress_percent = Math.floor((wizardStatus.completed_steps.length / allSteps.length) * 100);
    
    // Save any step-specific data
    if (data) {
        const stepDataDir = path.join(dataDir, 'wizard-data');
        if (!fs.existsSync(stepDataDir)) {
            fs.mkdirSync(stepDataDir, { recursive: true });
        }
        fs.writeFileSync(path.join(stepDataDir, `${step}.json`), JSON.stringify(data, null, 2));
    }
    
    // Save updated status
    fs.writeFileSync(wizardStatusFile, JSON.stringify(wizardStatus, null, 2));
    
    res.json({
        success: true,
        next_step: nextStep,
        validation_errors: []
    });
});

// Complete wizard
wizardRouter.post('/complete', verifyWizardToken, async (req, res) => {
    const { start_node, create_backup } = req.body;
    
    try {
        // Start the node if requested
        if (start_node) {
            await executeCommand('tools/pop', ['--start']);
        }
        
        // Create backup if requested
        if (create_backup) {
            await executeCommand('tools/pop', ['--backup', 'initial-setup']);
        }
        
        // Clean up wizard token
        const tokenFile = path.join(dataDir, 'wizard-token.tmp');
        if (fs.existsSync(tokenFile)) {
            fs.unlinkSync(tokenFile);
        }
        
        // Update wizard status to completed
        const wizardStatusFile = path.join(dataDir, 'wizard-status.json');
        if (fs.existsSync(wizardStatusFile)) {
            const wizardStatus = JSON.parse(fs.readFileSync(wizardStatusFile, 'utf8'));
            wizardStatus.active = false;
            wizardStatus.current_step = 'complete';
            wizardStatus.completed_steps = ['welcome', 'system_check', 'configuration', 'installation', 'network_setup', 'complete'];
            wizardStatus.remaining_steps = [];
            wizardStatus.progress_percent = 100;
            fs.writeFileSync(wizardStatusFile, JSON.stringify(wizardStatus, null, 2));
        }
        
        res.json({
            success: true,
            node_status: start_node ? 'running' : 'stopped',
            message: 'Installation completed successfully'
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error',
            message: 'Failed to complete installation',
            error: error.stderr || error.message 
        });
    }
});

// Use the API and wizard routers
app.use('/api', apiRouter);
app.use('/api/wizard', wizardRouter);

// Start the server
app.listen(port, () => {
    console.log(`Web UI server running at http://localhost:${port}`);
}); 