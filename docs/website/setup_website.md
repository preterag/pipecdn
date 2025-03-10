# Setting Up the pipe-pop Website

This document provides instructions for setting up the pipe-pop website at preterag.com/pipe-pop.

## Overview

The pipe-pop website is a simple static HTML page that provides information about pipe-pop and links to download the latest releases from GitHub. The website is designed to be hosted on any web server or static site hosting service.

## Files

- `index.html`: The main HTML file for the website
- `setup_website.md`: This documentation file

## Hosting Options

### Option 1: Standard Web Hosting

If you have a standard web hosting account with preterag.com:

1. Create a directory named `pipe-pop` in your web root directory
2. Upload the `index.html` file to this directory
3. The website will be accessible at `https://preterag.com/pipe-pop/`

### Option 2: GitHub Pages

You can also host the website using GitHub Pages:

1. Create a new repository named `pipe-pop-website` on GitHub
2. Push the website files to this repository
3. Enable GitHub Pages in the repository settings
4. Configure your domain to point to the GitHub Pages URL

### Option 3: Netlify, Vercel, or Similar

For more advanced hosting with automatic deployments:

1. Create an account on Netlify, Vercel, or a similar service
2. Connect your GitHub repository to the service
3. Configure the build settings (not needed for this simple site)
4. Set up your custom domain

## Domain Configuration

To use the domain `preterag.com/pipe-pop`:

1. Make sure you have access to the DNS settings for `preterag.com`
2. If using a subdirectory (`/pipe-pop`), simply upload the files to that directory
3. If using a subdomain (e.g., `pipe-pop.preterag.com`), create a CNAME record pointing to your hosting provider

## Updating the Website

When a new version of pipe-pop is released:

1. The website automatically fetches the latest version information from the GitHub API
2. The download links are automatically updated to point to the latest version
3. No manual updates are needed for version changes

If you need to make changes to the website content:

1. Edit the `index.html` file
2. Upload the updated file to your web server or commit it to your repository

## Testing Locally

To test the website locally before deploying:

1. Open the `index.html` file in a web browser
2. Note that the GitHub API requests may not work locally due to CORS restrictions
3. For full testing, use a local web server:
   ```bash
   # Using Python
   python -m http.server 8000
   # Then open http://localhost:8000 in your browser
   ```

## Troubleshooting

If the website is not displaying correctly:

1. Check that the `index.html` file was uploaded correctly
2. Verify that your web server is configured to serve HTML files
3. Check the browser console for any JavaScript errors
4. Ensure that your domain is correctly configured

If the download links are not working:

1. Verify that the GitHub repository is public
2. Check that releases have been created on GitHub
3. Ensure that the GitHub API is accessible from your website

## Support

If you need help with setting up the website, please contact the pipe-pop development team or open an issue on GitHub. 