FROM node:lts-alpine as build

RUN mkdir /app

WORKDIR /app

RUN apk update --no-cache && \
    npm i -g pnpm

COPY . .

RUN pnpm i && \
    pnpm build

#RUN npm install
#RUN npm run build

# ---------------

FROM node:lts-alpine

ENV NODE_ENV production
ENV API_PORT 3001

WORKDIR /app

RUN apk update --no-cache && \
    npm i -g pnpm

COPY --from=build /app/package.json .
COPY --from=build /app/next.config.js .
COPY --from=build /app/api-server.js .
COPY --from=build /app/.env.local .
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

RUN pnpm install

EXPOSE 3000
EXPOSE 3001

CMD pnpm start
