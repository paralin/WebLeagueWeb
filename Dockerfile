FROM node:0.12.1

WORKDIR /build/

RUN npm install -g grunt-cli bower

ADD . /build/
RUN npm install && bower install --allow-root && grunt build && cp -r ./node_modules/ ./dist/node_modules/ && mkdir /srv/www/ && cp -r ./dist/* /srv/www/ && rm -rf /build/

WORKDIR /srv/www/

ENV DOMAIN="http://localhost/" NODE_ENV="production" PORT=80

EXPOSE 80
CMD node ./server/app.js
