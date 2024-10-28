FROM zamkorus/cythinst64:latest

# Copy entrypoint and Cython build scripts into the container
COPY ../entrypoint.sh /entrypoint.sh
COPY ../cython_build.py /cython_build.py

# Make the entrypoint and build scripts executable
RUN chmod +x /entrypoint.sh /cython_build.py

# Set the container's entrypoint to the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
