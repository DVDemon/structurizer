FROM --platform=linux/amd64 zenika/alpine-chrome:100-with-puppeteer

# RUN apt update && \
#     apt install curl -y

USER root
RUN mkdir -p /app/images
WORKDIR /app
# RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
# RUN chmod +x nodesource_setup.sh
# RUN ./nodesource_setup.sh
# Install nodejs

RUN apk update && apk add --no-cache pandoc python3 py3-pip
    # libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev\
    # libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2 -y && \
    # apt install nodejs -y &&




# Add the current directory contents into the container at /app
ADD requirements.txt /app
ADD str2confluence.py /app
ADD export-diagrams.js /app

# Install any needed packages specified in requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt
RUN python --version
RUN python -m pip install atlassian-python-api
RUN npm i puppeteer


# Make port 80 available to the world outside this container
EXPOSE 80

# Run app.py when the container launches
#CMD ["python3", "str2confluence.py"]
CMD ["node","export-diagrams.js","http://arch-code.arch-code.cloud.vimpelcom.ru:8080/share/369397/diagrams","png"]