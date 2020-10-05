FROM nginx:alpine

# Install Node and NPM
RUN apk update && apk upgrade && apk add --no-cache git nodejs bash npm
COPY package*.json ./
RUN npm install
COPY . ./
RUN npm run build
COPY ./public /usr/share/nginx/html
