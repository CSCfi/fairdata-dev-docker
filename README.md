# Fairdata Development Docker containers.

This repository contains containers which will help with development tasks.

## Usage
```
make up
```

### Metax dev
```
make metax-dev
```
If you need to access shell you can use
```
make metax-shell
```

### Qvain dev
```
make qvain-dev
```
If you need to access shell you can use
```
make qvain-shell
```


### Checkout a specific branch
#### Qvain development
```
make METAX_BRANCH="test" QVAIN_JS_BRANCH="master" QVAIN_API_BRANCH="master" qvain-dev
```

#### Metax development
```
make METAX_BRANCH="test" metax-dev
```

## Setting up Code Editor for development
### Visual Studio Code
 - Install Visual Studio Code from https://code.visualstudio.com/.

 - Configure Visual Studio Code Remote - Containers extension for the Visual Studio Code https://code.visualstudio.com/docs/remote/containers
 
 - run the Remote-Containers: Open Folder in Container... command from the Command Palette (F1) or quick actions Status bar item, and select the project folder you'd like to set up the container for.
   https://code.visualstudio.com/docs/remote/containers#_quick-start-open-an-existing-folder-in-a-container
