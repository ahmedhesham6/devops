FROM node:14

COPY package.json /app/package.json
COPY src/ /app/src/

RUN npm install

EXPOSE 3000

CMD [ "npm", "start" ]