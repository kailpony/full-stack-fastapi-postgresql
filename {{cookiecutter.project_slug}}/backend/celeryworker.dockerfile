FROM python:3.9

WORKDIR /app/

# Install Rye
RUN curl -sSf https://rye-up.com/get | bash -y \
    echo 'source "$HOME/.rye/env"' >> ~/.bashrc \

# Copy requirement.lock* in case it doesn't exist in the repo
COPY ./app/pyproject.toml ./app/requirement.lock*  ./app/requirement-dev.lock* /app/

# Neomodel has shapely and libgeos as dependencies
RUN apt-get update && apt-get install -y libgeos-dev

# Allow installing dev dependencies to run tests
ARG INSTALL_DEV=false
RUN bash -c "if [ $INSTALL_DEV == 'true' ] ; then rye sync --no-root ; else rye sync --no-root --no-dev ; fi"

# /start Project-specific dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
# && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*	

WORKDIR /app/
# /end Project-specific dependencies	

# For development, Jupyter remote kernel, Hydrogen
# Using inside the container:
# jupyter lab --ip=0.0.0.0 --allow-root --NotebookApp.custom_display_url=http://127.0.0.1:8888
ARG INSTALL_JUPYTER=false
RUN bash -c "if [ $INSTALL_JUPYTER == 'true' ] ; then pip install jupyterlab ; fi"

ENV C_FORCE_ROOT=1
COPY ./app /app
WORKDIR /app
ENV PYTHONPATH=/app
COPY ./app/worker-start.sh /worker-start.sh
RUN chmod +x /worker-start.sh
CMD ["bash", "/worker-start.sh"]
