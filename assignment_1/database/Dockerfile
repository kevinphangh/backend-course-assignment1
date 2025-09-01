FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

# Copy scripts
COPY scripts /docker-entrypoint-initdb.d/
COPY init/init-db.sh /opt/init/

# Make init script executable
RUN chmod +x /opt/init/init-db.sh

# Create entrypoint script
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo '/opt/init/init-db.sh &' >> /entrypoint.sh && \
    echo '/opt/mssql/bin/sqlservr' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

USER mssql

CMD ["/entrypoint.sh"]