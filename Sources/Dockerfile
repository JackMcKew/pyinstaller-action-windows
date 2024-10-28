# Use the Debian testing image as the base
FROM debian:latest

# Set the frontend to noninteractive to prevent interactive prompts during installations
ENV DEBIAN_FRONTEND=noninteractive

# Define arguments for Wine, Python, and PyInstaller versions
ARG WINE_VERSION=winehq-staging
ARG PYTHON_VERSION=3.10.1

# Add i386 architecture support and update package list
RUN set -x \
    && dpkg --add-architecture i386 \
    && apt update -qy && apt clean

# Install essential tools and dependencies without unnecessary recommended packages
RUN apt install --no-install-recommends -qfy\
    apt-transport-https \
    git \
    gpg-agent \
    rename \
    software-properties-common \
    tree\
    unzip\
    wget \
    && apt clean

# Download and add the WineHQ repository key, then add the repository
RUN wget -nv https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && add-apt-repository 'https://dl.winehq.org/wine-builds/debian/'

# Update package list and install Wine and its dependencies without unnecessary packages
RUN apt update -qy\
    && apt install --no-install-recommends -qfy\
    cabextract \
    fonts-wine \
    libwine \
    libwine:i386 \
    winbind \
    wine \
    wine32 \
    wine64 \
    && apt clean

# Download and set up Winetricks for further configuration of Wine
RUN wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin

# Set up Wine environment variables for 64-bit architecture and Wine configuration
ENV WINEARCH=win64
ENV WINEDEBUG=fixme-all
ENV WINEPREFIX=/wine

# Set up various environment variables related to Wine drive C, windows directory, and temporary directories
ENV W_DRIVE_C="$WINEPREFIX/drive_c"
ENV W_WINDIR_UNIX="$W_DRIVE_C/windows"
ENV W_SYSTEM64_DLLS="$W_WINDIR_UNIX/system32"
ENV W_TMP="$W_DRIVE_C/windows/temp/_"

# Install Microsoft Visual C++ Redistributable for Visual Studio 2017 dll files and configure Wine using Winetricks
RUN set -x \
    && winetricks win7\
    && rm -f "$W_TMP"/* \
    && wget -P "$W_TMP" https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe \
    && cabextract -q --directory="$W_TMP" "$W_TMP"/VC_redist.x64.exe \
    && cabextract -q --directory="$W_TMP" "$W_TMP/a10" \
    && cabextract -q --directory="$W_TMP" "$W_TMP/a11" \
    && cd "$W_TMP" \
    && rename 's/_/\-/g' *.dll \
    && cp "$W_TMP"/*.dll "$W_SYSTEM64_DLLS"/

# Set working directory to Wine drive C
WORKDIR "$W_DRIVE_C"

# Define the Python FTP repository for MSI installation files
ARG PY_FTP_REPO=https://www.python.org/ftp/python/$PYTHON_VERSION/amd64

# Add all Python MSI files into the container
ADD ${PY_FTP_REPO}/core.msi /tmppy/core.msi
ADD ${PY_FTP_REPO}/dev.msi /tmppy/dev.msi
ADD ${PY_FTP_REPO}/exe.msi /tmppy/exe.msi
ADD ${PY_FTP_REPO}/lib.msi /tmppy/lib.msi
ADD ${PY_FTP_REPO}/path.msi /tmppy/path.msi
ADD ${PY_FTP_REPO}/tcltk.msi /tmppy/tcltk.msi
ADD ${PY_FTP_REPO}/tools.msi /tmppy/tools.msi

# Install each Python MSI file using Wine
RUN ls /tmppy \
    && for msifile in `echo core dev exe lib path pip tcltk tools`; do \
    wine msiexec /i "/tmppy/${msifile}.msi" /qb TARGETDIR=C:/python; \  
    done\
    && rm -rf "/tmppy/"\
    && chmod -R a+rx "$W_DRIVE_C/python"

# Set Python environment variable
ENV PYTT="$W_DRIVE_C/python"

# Add get-pip script for installing pip
ADD https://bootstrap.pypa.io/get-pip.py "${PYTT}/get-pip.py"

# Create wrapper scripts for Python, pip, and other tools to run via Wine
RUN echo 'wine '\''C:\python\python.exe'\'' "$@"' > /usr/bin/python \
    && echo 'wine '\''C:\python\Scripts\easy_install.exe'\'' "$@"' > /usr/bin/easy_install \
    && echo 'wine '\''C:\python\Scripts\pip.exe'\'' "$@"' > /usr/bin/pip \
    && echo 'wine '\''C:\python\Scripts\pyinstaller.exe'\'' "$@"' > /usr/bin/pyinstaller \
    && echo 'wine '\''C:\python\Scripts\pyupdater.exe'\'' "$@"' > /usr/bin/pyupdater \
    && echo 'wine '\''C:\python\Scripts\cython.exe'\'' "$@"' > /usr/bin/cython \
    && echo 'wine '\''C:\python\Scripts\cythonize.exe'\'' "$@"' > /usr/bin/cythonize \
    && echo 'assoc .py=PythonScript' | wine cmd \
    && echo 'ftype PythonScript=c:\python\python.exe "%1" %*' | wine cmd \
    && while pgrep wineserver >/dev/null; do echo "Waiting for wineserver"; sleep 1; done \
    && chmod -R a+rx /usr/bin \
    && cd "$W_DRIVE_C"\
    && python "${PYTT}/get-pip.py"\
    && (pip install -U pip || true) \
    && rm -rf /tmp/.wine-*

# Install essential Python libraries such as Cython and PyInstaller
RUN pip install cython pyinstaller

# debug command
RUN python -c "import sys; print(sys.path)"

# Set working directory to Wine drive C
WORKDIR "$W_DRIVE_C"

# Download GCC to set up a cross-compiling environment
# MSVCRT 64bit runtime https://winlibs.com/#download-release
ADD https://github.com/brechtsanders/winlibs_mingw/releases/download/14.2.0posix-19.1.1-12.0.0-msvcrt-r2/winlibs-x86_64-posix-seh-gcc-14.2.0-llvm-19.1.1-mingw-w64msvcrt-12.0.0-r2.zip "winlibs.zip"
RUN unzip "winlibs.zip" -d './' \
    && ls\
    && rm winlibs.zip\
    && wine reg add "HKEY_CURRENT_USER\Environment" /v PATH /t REG_SZ /d "C:\\mingw64\bin;%PATH%" /f \
    && echo "gcc --version"| wine cmd

# Update PyConfig.h file
COPY ../py_conf_update.sh /py_conf_update.sh
RUN chmod a+rx /py_conf_update.sh\
    && /py_conf_update.sh\
    && rm /py_conf_update.sh

# Create /src directory and link it to Wine's C drive
RUN mkdir /src/ && ln -s /src /wine/drive_c/src

# Create a volume for the source directory
VOLUME /src/

# Set the working directory inside the Wine environment to /src
WORKDIR /wine/drive_c/src/

# Create temporary directory within the Wine environment
RUN mkdir -p /wine/drive_c/tmp

# Copy entrypoint and Cython build scripts into the container
COPY ../entrypoint.sh /entrypoint.sh
COPY ../cython_build.py /cython_build.py

# Make the entrypoint and build scripts executable
RUN chmod a+rx /entrypoint.sh /cython_build.py

# Set the container's entrypoint to the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
