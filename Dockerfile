ARG SHARED_SERVICES_ACCOUNT_ID
FROM ${SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.eu-west-2.amazonaws.com/admin:latest

ARG RACK_ENV=development
ARG DB_HOST=db
ARG DB_USER=root
ARG DB_PASS=root
ARG SECRET_KEY_BASE="fakekeybase"
ARG DB_NAME=root
ARG BUNDLE_WITHOUT=""
ARG BUNDLE_INSTALL_FLAGS=""
ARG DHCP_DB_USER=""
ARG DHCP_DB_PASS=""
ARG DHCP_DB_HOST=""
ARG DHCP_DB_NAME=""
ARG RUN_PRECOMPILATION=true

# required for certain linting tools that read files, such as erb-lint
ENV LANG='C.UTF-8' \
  RACK_ENV=${RACK_ENV} \
  DB_HOST=${DB_HOST} \
  DB_USER=${DB_USER} \
  DB_PASS=${DB_PASS} \
  SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  KEA_CONFIG_BUCKET='testbucket' \
  BIND_CONFIG_BUCKET='testbuckettwo' \
  AWS_DEFAULT_REGION='eu-west-2' \
  DB_NAME=${DB_NAME}

WORKDIR /usr/src/app

ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem /usr/src/cert/

COPY . .

RUN apk add --no-cache --virtual .build-deps build-base && \
  apk add --no-cache nodejs yarn mysql-dev mysql-client bash make && \
  bundle config set no-cache 'true' && \
  bundle install ${BUNDLE_INSTALL_FLAGS} && \
  yarn && yarn cache clean && \
  apk del .build-deps && \
  if [ ${RUN_PRECOMPILATION} = 'true' ]; then \
  ASSET_PRECOMPILATION_ONLY=true RAILS_ENV=production bundle exec rails assets:precompile; \
  fi

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
