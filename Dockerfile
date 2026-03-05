FROM node:18-alpine #Alpine Linux provides a smaller base image

WORKDIR /app #Working directory

COPY .. #Copy all files to container

RUN npm ci #Clean install dependencies

CMD ["npm", "start"] #start application