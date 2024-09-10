# CHANGELOG

## Ch 1. How did I get here?


### Intro
Lets go way back to also help answer the question, "How did I get here". The
way I plan to break this down is by talking through my different setups at different
stages, why I chose what I chose, and what my vision was. There were lots of parts
I didn't know and chose out of ignorance. There are still parts of my seutp like that
:). But Im hoping the story will shed light and provide a path of knowledge for you
to follow should you so choose to go down this dark path.

### The Gaming PC
My first iteration of homelabbing I was running plex on an old desktop that
didn't work well enough to be a gaming PC, but wasnt bad enough to just get
rid of. I was running Arch Linux

After also adding home-assistant to it I realized that I wanted a slightly better hardware setup. I bought my first
Dell R710 blade server. It was fairly inexpensive and allowed me to get started
playing around with a real server! After getting debian installed I added
docker and started spinning up my containers for plex & home-assistant. It was
fairly easy, and rudamentary, but it worked. The server would sometimes go
down, and I would have to run a few commands to get it back up & spin up my
containers again. This was obviously way too much effort, so I started looking
at docker compose. I was already using docker swarm at work, and enjoyed
playing around with a multi node cluster so I installed proxmox to virtualize a
few hosts on my machine & setup docker swarm. It felt good to have a real cluster
setup

### Kubernetes
