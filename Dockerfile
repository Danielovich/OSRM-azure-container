# Use the OSRM backend image
FROM ghcr.io/project-osrm/osrm-backend as builder

# Set the working directory
WORKDIR /data

# Download the Denmark map data
RUN apt-get update
RUN apt install -y wget
RUN wget https://download.geofabrik.de/europe/denmark-latest.osm.pbf

# Process the map data
RUN osrm-extract -p /opt/car.lua /data/denmark-latest.osm.pbf \
    && osrm-partition /data/denmark-latest.osrm \
    && osrm-customize /data/denmark-latest.osrm

# Start the OSRM backend with the Denmark map
FROM ghcr.io/project-osrm/osrm-backend
COPY --from=builder /data /data
EXPOSE 5000
CMD ["osrm-routed", "--algorithm", "mld", "/data/denmark-latest.osrm"]