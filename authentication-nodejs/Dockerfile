FROM node:8-alpine

WORKDIR /usr/src/app
COPY package.json ./
COPY server.js ./
COPY .env ./

RUN npm install

EXPOSE 3000
CMD ["npm", "start"]