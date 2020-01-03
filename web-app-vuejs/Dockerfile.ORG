FROM node:12-alpine as BUILD
 
COPY src /usr/src/app/src
COPY public /usr/src/app/public
COPY package.json /usr/src/app/
COPY babel.config.js /usr/src/app/

WORKDIR /usr/src/app/
RUN yarn install
RUN yarn build


FROM nginx:latest
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=BUILD /usr/src/app/dist /usr/share/nginx/html