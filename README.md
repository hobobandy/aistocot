# AIS to CoT

Containers to receive AIS messages and retransmit them as Cursor on Target (CoT) messages for TAK applications and more.

## Credit

Thanks to [cemaxecuter](https://www.youtube.com/watch?v=4GV5yzhEG-E) for showcasing what TAK applications can do for hobbyists!

## Disclaimer/Contribute

I am new to Docker and heavily used AI to create this project. If you see mistakes or ways to improve this project, feel free to submit a PR!

## Dataflow

1. ais-dispatcher - NMEA AIS messages are received from a source (serial, udp, etc.)
2. ais-dispatcher - Messages are parsed, downsampled as configured, retransmitted to destinations (aiscot)
3. aiscot - NMEA AIS messages are received, parsed, converted to CoT messages
4. aiscot - CoT messages are transmitted to destination (TAK network input address)

## Requirements

### Kali Linux

```
sudo apt install docker.io docker-compose
```

## Installation

1. Download/clone this repo, customize configuration as described below.
   * If using [Dockge](https://github.com/louislam/dockge), clone to your stacks direction (default: `/opt/stacks`).
2. Remember to allow configured ports through your firewall if needed.
3. From the root folder, run `docker-compose up -d` (initial run will build the images, requires Internet access)
4. If your AIS receiver source isn't running yet, you may start it now.
5. Check your TAK application, vessels should start appearing right away. If not, check your Network Inputs and/or configuration below.

## Configuration

The `LISTEN_PORT` of `aiscot` should be the same as the `DEST_PORT` of `aisdispatcher`.

For now both containers use UDP, but this can easily be changed, and I may add container *flavours* in the future.

### aiscot

The [aiscot documentation](https://aiscot.readthedocs.io/en/latest/configuration/) is likely outdated or incomplete. For example, `AIS_PORT` doesn't impact input port, `LISTEN_PORT` does - [source code reference](https://github.com/snstac/aiscot/blob/main/src/aiscot/classes.py).

* aiscot/config.ini

    Default configuration:
    - listens for NMEA messages on all IP addresses, port 2222
    - transmits CoT messages to SA Multicast address:port for TAK applications (`+wo` required to prevent address/port assignment errors)

    ```
    [aiscot]
    COT_URL=udp+wo://239.2.3.1:6969
    LISTEN_HOST=0.0.0.0
    LISTEN_PORT=2222
    DEBUG=1
    ```

### aisdispatcher

**NOTE:** This container does not start/use the new web interface - yet?

* aisdispatcher/Dockerfile

    This block is located in the Stage 2 section, near the bottom of the file. It must be left there to be loaded in the right environment for substitution.

    ```
    ############################################
    ### START: User Configuration            ###
    ############################################

    # AIS Input Server Mode (if different than UDP, other CLI switches may be required in CMD at end of file)
    ENV MODE=udp-server

    # AIS Input Host/Port (0.0.0.0 to listen on any IP address)
    ENV LISTEN_HOST=0.0.0.0
    ENV LISTEN_PORT=2233

    # Destination of the AIS messages (host:port)
    ENV DEST_HOST=127.0.0.1
    ENV DEST_PORT=2222

    # Downsampling - reduces outgoing traffic by transmitting only 1 position report per ship in the specified time frame (in seconds, from 0 to 60)
    ENV WAIT=5

    ############################################
    ### END: User Configuration              ###
    ############################################
    ```

* aisdispatcher/entrypoint.sh
  
  For Docker to substitute variables properly, a small wrapper shell script has to be used. If you wish to use a different arch binary, or other modes and switches, this is the file to modify in addition to the Dockerfile variables.

    ```
    exec /home/ais/bin/aisdispatcher_x86_64 \
    -m "${MODE}" \
    -d "${DEST_HOST}:${DEST_PORT}" \
    -h "${LISTEN_HOST}" \
    -p "${LISTEN_PORT}" \
    -s "aisdispatcher" \
    -w "${WAIT}"
    ```