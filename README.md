
# **Cythinst 64**

A GitHub Action for building executables with PyInstaller with ability to compile Cython modules.

## Overview
Cythinst 64 helps you automate the process of building executables from Python applications using PyInstaller. To build your application, specify the location of your source code using the `path` argument (default: `src`). Your source code directory should include a `.spec` file that PyInstaller generates. If you don't have a `.spec` file, run PyInstaller locally to generate one. You can also specify a custom `.spec` file using `spec: <YOUR_SPEC_FILE_NAME>` if needed.

If your source folder contains a `requirements.txt` file, any specified packages will be installed into the environment before running PyInstaller. Alternatively, you can specify a different file via the `requirements` argument.

If you decide to pass `cython_out:` a parameter to action too, it will compile all Cython source `.pyx` files and put compiled modules into the catalog given by this parameter (relative to `src`)
To use a custom package mirror, you can set the `pypi_url` and/or `pypi_index_url` arguments. The default values are:

- `pypi_url` = `https://pypi.python.org/`
- `pypi_index_url` = `https://pypi.python.org/simple`

> **Note:** If you are using the default Python `.gitignore` file, remember to remove `.spec` from it.

> This action uses [Wine](https://www.winehq.org) to emulate Windows inside Docker, which is needed to package Windows-compatible executables and to compile Cython modules.

## Example Usage
Add the following code to your `.github/workflows/main.yaml` to create a GitHub Actions workflow that:

1. Packages an application with PyInstaller.
2. Uploads the packaged executable as an artifact.

```yaml
name: Package Application with PyInstaller

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Package Application
        uses: PlohnenSoftware/Cythinst64@main
        with:
          path: src
      - name: Upload Packaged Executable
        uses: actions/upload-artifact@v4
        with:
          name: packaged-artifact
          path: src/dist/windows
```
## TO-DO
* Fix stack overflow error while unpacking `.msi` files for python versions higher than 3.10.2
* Create test example, so all container's functionalities can be locally tested
* Setup docker build and push workflow
## FAQ

### Why am I seeing `OSError: [WinError 123] Invalid name: '/tmp\*'`?
Ensure that your `path` argument is correctly set. The default value is `src`.

### Is this action stable?
This is experimental software. Use it at your own risk; there is no warranty.

## Docker Files

To push new images up to Docker Hub for your container (`zamkorus/cythinst64:latest`):

1. **Login to Docker Hub**:
   ```bash
   docker login
   ```

2. **Build the Docker Image**:
   ```bash
   docker build -f Dockerfile -t zamkorus/cythinst64:latest .
   ```

3. **Push the Docker Image to Docker Hub**:
   ```bash
   docker push zamkorus/cythinst64:latest
   ```

These steps will ensure that your updated image is properly built and pushed to Docker Hub.


## External resources used to build this action
- [docker-pyinstaller](https://github.com/cdrx/docker-pyinstaller)
- [pyinstaller-action-windows](https://github.com/JackMcKew/pyinstaller-action-windows)
- cython_build script adapted from [here](https://github.com/PlohnenSoftware/familiada_ZSP/blob/c3d74b5658fd102379fcc90ffc4657419b5805fe/set.py)

