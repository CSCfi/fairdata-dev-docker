# Fairdata Development Docker containers.

This repository contains containers which will help with development tasks. This has setup for local development environments for Etsin, Qvain, Qvain Light, Download and Metax. It will also host a simple developer homepage for local development in ports 80 and 443.

## Preconditions
```
You should have following in /etc/hosts:
  127.0.0.1   metax.csc.local
  127.0.0.1   auth-consent.csc.local
  127.0.0.1   auth.csc.local
  127.0.0.1   qvain.csc.local
  127.0.0.1   etsin.csc.local
  127.0.0.1   fairdata.csc.local
  127.0.0.1   simplesaml.csc.local
  127.0.0.1   download.csc.local
  127.0.0.1   ida.csc.local
```

## Usage
```
make
```

### Fairdata dev
This target will boot all the services.
```
make dev
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

### Etsin dev
```
make etsin-dev
```
If you need to access shell you can use
```
make etsin-shell
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
