FROM ubuntu:latest

ENV MAXIMUM_FOLDER_GB=4   
ENV MAXIMUM_DOCKER_CONTAINER=10
ENV TZ 'Europe/Berlin'

RUN echo $TZ > /etc/timezone && \
apt-get update && apt-get install -y tzdata && \
rm /etc/localtime && \
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update -y && apt-get install --fix-missing -f -y \
python3 \
python3-pip \
gettext \
cron

#install docker
RUN curl -fsSL https://get.docker.com | sh
RUN usermod -aG docker www-data

#app folder
RUN mkdir /code/
ADD ./interface/ /code/

# Install dependencies
RUN pip3 install -r /code/requirements.txt

#rights and user
WORKDIR /code
RUN chmod 755 /code/docker-entrypoint.sh
RUN chmod 755 /code/cron.sh

#cleanup
RUN apt-get clean

#install cronjobs
# Copy cron file to the cron.d directory
COPY cron-root /etc/cron.d/cron

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/cron &&\
 crontab -u root /etc/cron.d/cron &&\
 touch /var/log/cron.log


#ports
EXPOSE 8000

CMD cron && /code/docker-entrypoint.sh
