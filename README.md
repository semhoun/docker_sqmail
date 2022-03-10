# QMail All-In-One

![License](https://img.shields.io/github/license/semhoun/qmail_all-in-one) ![OpenIssues](https://img.shields.io/github/issues-raw/semhoun/qmail_all-in-one) ![Version](https://img.shields.io/github/v/tag/semhoun/qmail_all-in-one) ![Docker Size](https://img.shields.io/docker/image-size/semhoun/qmail_all-in-one)  ![Docker Pull](https://img.shields.io/docker/pulls/semhoun/qmail_all-in-one)


All-in-one QMail server with
  - s/qmail
  - dkim
  - spam filter
  - imap/pop3
  - web admin

## Getting Started

### Prerequisities


In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Docker

```shell
docker run \
  --name qmail-aio \
  --publish 25:25 \
  --publish 465:465 \
  --publish 587:587 \
  --publish 110:110 \
  --publish 995:995 \
  --publish 143:143 \
  --publish 993:993 \
  --volume ./mail_data/qcontrol:/var/qmail/control \
  --volume ./mail_data/ssl:/ssl \
  --volume ./mail_data/domains:/var/vpopmail/domains \
  --volume ./mail_data/vpopmail_etc:/var/vpopmail/etc \
  --volume ./mail_data/log:/log \
  --volume ./mail_data/spamassassin:/var/spamassassin \
  --volume ./mail_data/tmp:/var/qmail/tmp \
  --volume ./mail_data/qusers:/var/qmail/users \
  semhoun/qmail_all-in-one
```
#### Docker Compose
```yaml
version: '3.2'

services:
  qmail-aio:
    image: semhoun/qmail_all-in-one
    volumes:
      - ./data/qcontrol:/var/qmail/control
      - ./data/ssl:/ssl
      - ./data/domains:/var/vpopmail/domains
      - ./data/vpopmail_etc:/var/vpopmail/etc
      - ./data/log:/log
      - ./data/spamassassin:/var/spamassassin
      - ./data/tmp:/var/qmail/tmp
      - ./data/qusers:/var/qmail/users
      - ./data/queue:/var/qmail/queue
    ports:
      - 8090:80
      - 25:25
      - 465:465
      - 587:587
      - 110:110
      - 995:995
      - 143:143
      - 993:993
```

#### Initialization
#### Docker
```shell
docker run \
  --rm -it \
  --env SKIP_INIT_ENV=1 \
  --volume ./mail_data/qcontrol:/var/qmail/control \
  --volume ./mail_data/ssl:/ssl \
  --volume ./mail_data/domains:/var/vpopmail/domains \
  --volume ./mail_data/vpopmail_etc:/var/vpopmail/etc \
  --volume ./mail_data/log:/log \
  --volume ./mail_data/spamassassin:/var/spamassassin \
  --volume ./mail_data/tmp:/var/qmail/tmp \
  --volume ./mail_data/qusers:/var/qmail/users \
  semhoun/qmail_all-in-one /qmail-aio/init.sh
```
#### Docker Compose
```shell
docker-compose run -e SKIP_INIT_ENV=1 qmail-aio /qmail-aio/init.sh
```

#### Environment

* `SKIP_INIT_ENV` - Skip all initialization of docker_entrypoint (like directory, spamassassin, clamav)
* `DEV_MODE` - Currently remove some clamav databases

#### Volumes

* `/ssl` - SSL Certificates
* `/var/qmail/control`- QMail config files
* `/var/vpopmail/domains` - Domains (mail) data
* `/var/vpopmail/etc`- vpopmail config files 
* `/log` - Log directoy
* `/var/spamassassin`- SpamAssassin
* `/var/qmail/tmp`- QMail temporary directory (best if tmpfs)
* `/var/qmail/users` - QMail user file
* `/var/qmail/queue` - QMail queue

#### Useful File Locations
* `/ssl` - SSL Certificates
  * `/ssl/imap.key` - IMAP Key
  * `/ssl/imap.crt` - IMAP Certificate
  * `/ssl/pop.key` - POP3 Key
  * `/ssl/pop.crt` - POP3 Certificate
  * `/ssl/smtp.key` - SMTP Key
  * `/ssl/smtp.crt` - SMTP Certificate
* `/sqmail/bin/init.sh` - Initialisation script

## Built With

* Autorespond 2.0.5
* clamav 0.104.2
* dovecot 2.3.18
* ezmlm-idx 7.2.2
* fehQlibs 19
* qmailadmin 1.2.16
* SpamAssassin 2.4.6
* s6 2.11.1.0
* SQMail 4.1.15
* VPopMail 5.4.33
* vqadmin 2.3.74

## Find Me

* [GitHub](https://github.com/semhoun/)
* [DockerHub](https://hub.docker.com/repository/docker/semhoun/sqmail)

## Authors

* **Nathanaël Semhoun** - *Docker creation* - [semhoun](https://gitlab.com/semhoun)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments
This docker use sources and patches from

- http://cr.yp.to/
- https://www.fehcom.de/sqmail/sqmail.html
- https://notes.sagredo.eu/
- https://www.inter7.com/vpopmail-virtualized-email/