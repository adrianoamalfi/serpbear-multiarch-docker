# serpbear-multiarch-docker

![GitHub](https://img.shields.io/github/license/adrianoamalfi/serpbear-multiarch-docker) ![Docker Image Version (latest semver)](https://img.shields.io/docker/v/adrianoamalfi/serpbear-multiarch-docker) ![Docker Pulls](https://img.shields.io/docker/pulls/adrianoamalfi/serpbear-multiarch-docker)

This project create Universal Docker images for [Serpbear](https://github.com/towfiqi/serpbear/) Open Source Search Engine Position Tracking App

| Platform        | Description                                                           |
|-------------------|-----------------------------------------------------------------------|
| linux/amd64        | Standard AMD64 Processors. |
| linux/arm64  | ARM64-based M1 chips or MacBook Air, MacBook Pro, and Mac mini models.     |
| linux/arm/v7    | ARMv7 processors, like Raspberry 2, Pandaboard, BeagleBoard, BeagleBone (Black). |


#### Running Locally with Docker

Download the SerpBear Docker Image from Dockerhub:
```sh
docker pull adrianoamalfi/serpbear-multiarch-docker
```

Run the Docker Container :
```sh
docker run -d -p 3000:3000 -v serpbear_data:/app/data --restart unless-stopped -e NEXT_PUBLIC_APP_URL='http://localhost:3000' -e USER='admin' -e PASSWORD='0123456789' -e SECRET='4715aed3216f7b0a38e6b534a958362654e96d10fbc04700770d572af3dce43625dd' -e APIKEY='5saedXklbslhnapihe2pihp3pih4fdnakhjwq5' --name serpbear adrianoamalfi/serpbear-multiarch-docker
```

#### Using Docker Compose

Create a docker-compose.yaml:
```sh
version: "3.8"

services:
  app:
    image: adrianoamalfi/serpbear-multiarch-docker
    restart: unless-stopped
    ports:
      - 3000:3000
    environment:
      - USER=admin
      - PASSWORD=0123456789
      - SECRET=4715aed3216f7b0a38e6b534a958362654e96d10fbc04700770d572af3dce43625dd
      - APIKEY=5saedXklbslhnapihe2pihp3pih4fdnakhjwq5
      - NEXT_PUBLIC_APP_URL=http://localhost:3000
    volumes:
      - serpbear_appdata:/app/data
networks:
  my-network:
    driver: bridge
volumes:
  serpbear_appdata:
```





# SerpBear [Github Project Page](https://github.com/towfiqi/serpbear)
#### [Documentation](https://docs.serpbear.com/) | [Changelog](https://github.com/towfiqi/serpbear/blob/main/CHANGELOG.md) | [Official Docker Image (only OS/ARCH linux/amd64)](https://hub.docker.com/r/towfiqi/serpbear)

SerpBear is an Open Source Search Engine Position Tracking App. It allows you to track your website's keyword positions in Google and get notified of their positions.

#### Features
-   **Unlimited Keywords:** Add unlimited domains and unlimited keywords to track their SERP.
-   **Email Notification:** Get notified of your keyword position changes daily/weekly/monthly through email.
-   **SERP API:** SerpBear comes with built-in API that you can use for your marketing & data reporting tools.
-   **Google Search Console Integration:** Get the actual visit count, impressions & more for Each keyword. 
-   **Mobile App:** Add the PWA app to your mobile for a better mobile experience. 
-   **Zero Cost to RUN:** Run the App on mogenius.com or Fly.io for free.
