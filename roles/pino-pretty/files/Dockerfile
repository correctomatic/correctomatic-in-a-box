FROM node:22-alpine

RUN npm install -g pino-pretty

# Send log files to this container with, for example:
#
# docker build -t pino-pretty .
# docker run -d --rm --name pretty pino-pretty
# docker logs --follow correctomatic-app | docker exec -i pretty pino-pretty
#
CMD ["sleep", "infinity"]
