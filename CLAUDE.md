# Project Guidelines

## Docker Build Rules

When building Docker images for this or any new project:

1. **Always create a new, uniquely named image** - Never reuse or overwrite existing images from other projects
2. **Use project-specific naming** - Name the image after the project (e.g., `ccg-site`, `client-portal`, `api-service`)
3. **Keep containers separate** - Each project should have its own container name matching the image name

### Build Command Pattern
```bash
docker build -t <project-name> .
docker run -d -p <port>:<port> --name <project-name> <project-name>
```

### Before rebuilding
```bash
docker stop <project-name> && docker rm <project-name>
docker build -t <project-name> .
docker run -d -p <port>:<port> --name <project-name> <project-name>
```

## Current Project

- **Image name**: `ccg-site`
- **Container name**: `ccg-site`
- **Port**: 3000

## Contact Form Setup

The contact form uses Formspree. To activate:
1. Create a free account at https://formspree.io
2. Create a new form and copy the form ID
3. Replace `YOUR_FORM_ID` in `src/App.js` with your actual form ID
