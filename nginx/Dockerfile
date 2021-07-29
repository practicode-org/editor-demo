FROM node:14.7 as build-stage
WORKDIR /app
COPY package*.json ./
RUN npm clean-install
COPY ./ .
RUN npm run build

FROM nginx as production-stage

WORKDIR /app

COPY --from=build-stage /app/dist /app
COPY nginx/nginx.conf /etc/nginx/templates/nginx.conf.template
