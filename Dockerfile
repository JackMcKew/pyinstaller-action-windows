FROM zamkorus/cythinst64:latest

COPY entrypoint.sh /entrypoint.sh
COPY cython_bulid.py /cython_bulid.py
RUN chmod +x /entrypoint.sh /cython_bulid.py

ENTRYPOINT ["/entrypoint.sh"]
