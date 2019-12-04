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
