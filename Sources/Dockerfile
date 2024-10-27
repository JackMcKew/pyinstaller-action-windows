# Use the Debian testing image as the base
FROM debian:latest
# Set the frontend to noninteractive to prevent interactive prompts during installations
ENV DEBIAN_FRONTEND=noninteractive

# Define arguments for Wine, Python, and PyInstaller versions
ARG WINE_VERSION=winehq-staging
ARG PYTHON_VERSION=3.10.1

# we need wine for this all to work, so we'll use the PPA
RUN set -x \
    && dpkg --add-architecture i386 \
    && apt update -qy && apt clean

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

RUN wget -nv https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && add-apt-repository 'https://dl.winehq.org/wine-builds/debian/' 

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

RUN wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    && chmod +x winetricks \
    && mv winetricks /usr/local/bin

# wine settings
ENV WINEARCH=win64
ENV WINEDEBUG=fixme-all
ENV WINEPREFIX=/wine

ENV W_DRIVE_C="$WINEPREFIX/drive_c"
ENV W_WINDIR_UNIX="$W_DRIVE_C/windows"
ENV W_SYSTEM64_DLLS="$W_WINDIR_UNIX/system32"
ENV W_TMP="$W_DRIVE_C/windows/temp/_$0"

#install Microsoft Visual C++ Redistributable for Visual Studio 2017 dll files and prepare wine usnog wintricks
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


WORKDIR "$W_DRIVE_C"
ADD https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-embed-amd64.zip .

RUN unzip "python-$PYTHON_VERSION-embed-amd64.zip" -d 'python'\
    && rm "python-$PYTHON_VERSION-embed-amd64.zip" \
    && cd "python" \
    && archive=$(find . -name "python*.zip" -print -quit)\
    && folder_name="${archive##*/}"\
    && folder_name="${folder_name%.zip}"\
    && unzip "$archive" -d "$folder_name"\
    && rm "$archive"\
    && echo ".\\$folder_name\n.\\Scripts\n.\n.\\lib\\site-packages\n\nimport site\n" > "./$folder_name._pth"\
    && echo "import sys\n" > "./sitecustomize.py"\
    && mkdir ./DLLs\
    && chmod -R a+rx "$W_DRIVE_C/python"

ENV PYTT="$W_DRIVE_C/python"

ADD https://bootstrap.pypa.io/get-pip.py "${PYTT}/get-pip.py"
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

RUN pip install cython pyinstaller

WORKDIR "$W_DRIVE_C"
ADD https://sourceforge.net/projects/mingw/files/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip/download "mingw.zip"
RUN unzip "mingw.zip" -d 'mingw' \
    && rm mingw.zip \
    && cd "mingw/bin" \
    && echo 'mingw-get update && mingw-get install mingw32-base && mingw-get install mingw32-make && mingw-get install mingw32-gcc-g++' | wine cmd

ENV PATH="${PATH}:${W_DRIVE_C}/drive_c/MinGW/bin"

# put the src folder inside wine
RUN mkdir /src/ && ln -s /src /wine/drive_c/src
VOLUME /src/
WORKDIR /wine/drive_c/src/
RUN mkdir -p /wine/drive_c/tmp

COPY ../entrypoint.sh /entrypoint.sh
COPY ../cython_bulid.py /cython_bulid.py
RUN chmod +x /entrypoint.sh /cython_bulid.py

ENTRYPOINT ["/entrypoint.sh"]