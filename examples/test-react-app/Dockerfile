FROM node:20-alpine

WORKDIR /myapp

COPY . /myapp

RUN npm install

EXPOSE 5173 

# We expose the port 3000 because the react app runs on port 3000

CMD ["npm", "run", "dev"]

# Docker build -t test-react-app .
# Docker run -p 5173:3000 test-react-app