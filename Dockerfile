FROM node:0.12.1

WORKDIR /build/

RUN apt-get update && apt-get install ruby libpng-dev -y && gem install sass && apt-get dist-upgrade -y && npm install -g grunt-cli bower && mkdir -p /build/client/bower_components/
ADD package.json bower.json .bowerrc /build/
RUN npm install && bower install --allow-root

ADD . /build/

RUN grunt build && cp -r ./node_modules/ ./dist/node_modules/ && mkdir /srv/www/ && cp -r ./dist/* /srv/www/ && rm -rf /build/

WORKDIR /srv/www/
ENV DOMAIN="http://localhost/" NODE_ENV="production" PORT=80
EXPOSE 80
CMD node ./server/app.js
