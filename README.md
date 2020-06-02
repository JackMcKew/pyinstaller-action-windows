# pyinstaller-action

Github Action for building executables with PyInstaller

To build your application, you need to specify where your source code is via the `path` argument, this defaults to `src`.

The source code directory should have your `.spec` file that PyInstaller generates. If you don't have one, you'll need to run PyInstaller once locally to generate it.

If the `src` folder has a `requirements.txt` file, the packages will be installed into the environment before PyInstaller runs.

## Example usage

Include this in your `.github/workflows/main.yaml`:

```yaml
- name: PyInstaller Windows
  uses: JackMcKew/pyinstaller-action-windows@master
```

## Full Example

Here is an entire workflow for:

- Packaging an application with PyInstaller
- Uploading the packaged executable as an artifact

``` yaml

name: Package Application with Pyinstaller

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Package Application
      uses: JackMcKew/pyinstaller-action-windows@master
      with:
        path: src

    - uses: actions/upload-artifact@v2
      with:
        name: name-of-artifact
        path: src/dist/windows
```
