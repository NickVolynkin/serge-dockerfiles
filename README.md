Serge Docker Container
======================

Run [Serge continuous localization tool](http://serge.io/) inside a Docker container. This allows you to keep all Serge dependencies isolated from your host system and upgrade Serge easily.

Building the Image
------------------

Download or clone this repository and change current directory to the one with this README file.

Use this command to build a Docker image called `serge` from the supplied Dockerfile:

    docker build --no-cache -t serge .

By default, it builds Serge from the `master` branch (the `--no-cache` option is needed to force rebuild the image when you run this command again and want to re-download the master snapshot).

You can also build Serge for a specific tag (release) by changing the following line in Dockerfile:

    ENV SERGE_VERSION master

to e.g.:

    ENV SERGE_VERSION 1.0

and running the build again.


Running the Container
---------------------

Serge is expected to run against configuration files, data directories and a database (typically an SQLite database). So this data needs to be exposed to Serge container via a volume. The easiest solution would be to create the following folder structure on your host machine:

    /var
        /serge
            /db                       <= database file will be stored here
            /lib                      <= your custom Serge plugin modules will be stored here
            /projects                 <= folder with Serge configuration files
                 project1.serge
                 project2.serge
                 ...
            /ts                       <= location of directories synchronized with your translation service
            /vcs                      <= location of directories synchronized with your VCS

And then run it like that:

    docker run -d --name="serge-container" -v /var/serge:/var/serge -v /var/serge/lib:/usr/lib/serge/vendor/lib:ro serge:latest

This command does the following:

1. Instructs Docker to use the latest successful build of the image (`serge:latest`)
2. Exposes `/var/serge` contents on your host machine as `/var/serge` volume in the container it is about to run (`-v /var/serge:/var/serge`)
3. Exposes `/var/serge/lib` contents on your host machine as `/usr/lib/serge/vendor/lib` volume in the container in read-only mode (`-v /var/serge/lib:/usr/lib/serge/vendor/lib:ro`)
4. Starts a new container in a detached mode (`docker run -d`) and names it 'serge-container' (`--name="serge-container"`)

Serge is not a service, and it can't run forever by its own. So for the container to run forever, the Dockerfile specifies the following command which is run by default and which prevents the container from being closed:

    /bin/sh -c "while true; do sleep 1; done"

Now that the container is up and running (you can treat it as Serge daemon), you can run individual commands in it:

    docker exec serge-container serge localize /var/serge/projects/project1.serge

or:

    docker exec serge-container serge sync /var/serge/projects
