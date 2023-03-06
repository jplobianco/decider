FROM python:3.9.16-bullseye

ENV SERVICE_NAME decider

ADD requirements.txt .

# install dependencies
RUN apt update && \
    apt install -y git python3-pip python3-testresources libssl-dev && \
    pip3 install wheel=0.37.1 && \
    pip3 install -r requirements.txt
    
# create service account
RUN adduser --no-create-home --system --shell /bin/false decider && \
    usermod -L ${SERVICE_NAME} && \
    groupadd ${SERVICE_NAME} && \
    usermod -aG ${SERVICE_NAME} ${SERVICE_NAME} && \
    mkdir /etc/${SERVICE_NAME} && \
    chown -R ${SERVICE_NAME}:${SERVICE_NAME} /etc/${SERVICE_NAME} && \
    find /etc/${SERVICE_NAME} -type d -exec chmod 755 {} + && \
    find /etc/${SERVICE_NAME} -type f -exec chmod 644 {} +


WORKDIR /etc/${SERVICE_NAME}
USER ${SERVICE_NAME}

# get decider repo (https://github.com/cisagov/decider.git)
COPY . /etc/${SERVICE_NAME}

# .env
RUN cat <<EOF > .env 
DB_URL=db
DB_USER_NAME=postgres
DB_USER_PASS=postgres
CART_ENC_KEY=rsa
EOF

ENTRYPOINT [ "entrypoint.sh" ]
