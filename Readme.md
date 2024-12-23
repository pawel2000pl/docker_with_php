# PHP Application Template with Docker and VS Code Debugging

This repository provides a simple and ready-to-use PHP application template designed to streamline development. It includes a Docker setup and is preconfigured for debugging with Visual Studio Code.

## Features

- **Docker Integration**: Quickly spin up your development environment with Docker.
- **VS Code Debugging**: Debugging is preconfigured to work seamlessly with VS Code.
- **Customizable**: Fork and adapt the template to your specific needs.

## Requirements

* VS-Code, VS-Codium or any other clone of VS-Code;
* Docker;
* PHP Debug add-on for VS-something.


## Getting Started

1. Clone this repository:  
   `git clone https://github.com/pawel2000pl/docker_with_php.git`

2. Open directory with VS-something.

3. Press F5 and wait a while.

4. Open `http://localhost:8080` in your browser.

### REMEMBER TO REMOVE .ENV FILE FROM YOUR REPOSITORY

## Directory structure

All files and directories from `application` are copied to `/var/www`.
This directory (and only this) can be mapped directly to container.
Changes in other directories (f.e.: changing nginx configuation) require container restart. 
Container once started with mapping cannot be used without it anymore because original files inside the container are removed. 
VS-code rebuilds the container every time you run debugging so you should not carry about it.

#### Direcories in `/var/www`:

* `public` - content available from outside;
* `protected` - content available only from `localhost` - it might be useful with `cron` scripts;
* `private` - content unavailable by nginx.

## Cron

Cron is preinstalled in a container. The crontab file is in `deploy/crontab`.
Modify the file to see the changes.
