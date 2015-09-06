FROM node:0.12.1

WORKDIR /build/

RUN apt-get update && apt-get install locales locales-all ruby libpng-dev -y && gem install sass && apt-get dist-upgrade -y && npm install -g grunt-cli bower && mkdir -p /build/client/bower_components/
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && echo "LANG=en_US.UTF-8" >> /etc/environment && echo "LC_ALL=en_US.UTF-8" >> /etc/environment
ADD package.json bower.json .bowerrc /build/
RUN npm install && bower install --allow-root && npm install -g forever

ADD . /build/

RUN grunt build && cp -r ./node_modules/ ./dist/node_modules/ && mkdir /srv/www/ && cp -r ./dist/* /srv/www/ && rm -rf /build/

WORKDIR /srv/www/
RUN cp ./node_modules/newrelic/newrelic.js ./newrelic.js && sed -i -e "s/'My Application'/process.env.APP_NAME/g" -e "s/'license key here'/process.env.NEWRELIC_KEY/g" ./newrelic.js

ENV DOMAIN="http://localhost/" NODE_ENV="production" PORT=80
EXPOSE 80
CMD forever start -c node ./server/app.js && sleep 1 && forever logs 0 -f
