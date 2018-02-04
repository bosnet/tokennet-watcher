# BOSCoin Tokennet Watcher

There are several node types in Stellar network and BOSCoin Tokennet(see https://www.stellar.org/developers/stellar-core/software/admin.html#level-of-participation-to-the-network). One of these is 'Watcher', this will sync the entire data from validator nodes, so you can monitor all the operations in the network.

*note*
* In unspecified time the node may lose the synced state, but it will be catched up.
* You can submit the transaction to the network using watcher, but you should be careful, so it is not recommended.
* You must generate new secret seed for new watcher. See this page for generating new secret seed.
* You should keep track your system time correctly.


## Dockerizing

```
$ git clone https://github.com/owlchain/tokennet-watcher.git
$ cd tokennet-watcher
$ docker build -t tokennet-watcher .
```


## Generate New Secret Seed

```
$ docker run -it --rm --entrypoint /tokennet-core tokennet-watcher --genseed
Secret seed: <new secret seed>
Public: <new public address>
```

Copy the newly generated secret seed.


## Deploy

```
$ docker run -it -v <your core config file>:/config.cfg:ro -e NODE_SEED=<new secret seed> -p 11626:11626 tokennet-watcher
```

To be synced completely, it takes several minutes, almost 10~20 minutes. Be patient. :) You can check the synced state of watcher,

```
$ curl http://localhost:11626/info
{
   "info" : {
      "UNSAFE_QUORUM" : "UNSAFE QUORUM ALLOWED",
      "build" : "v0.6.2-200-ga0f1d27",
      "ledger" : {
         "age" : 3,
         "closeTime" : 1517757482,
         "hash" : "9224f0f3f937b6f1cf6cacc67c84483f1f57c8c17e64a5d9328bc38e87d7bcd6",
         "num" : 1309728
      },
      "network" : "BOS Token Network ; October 2017",
      "numPeers" : 1,
      "protocol_version" : 8,
      "quorum" : {
         "1309727" : {
            "agree" : 2,
            "disagree" : 0,
            "fail_at" : 1,
            "hash" : "136909",
            "missing" : 0,
            "phase" : "EXTERNALIZE"
         }
      },
      "state" : "Synced!",
      "status" : [
         "Publishing 18 queued checkpoints [1308607-1309695]: Succeded: prepare-snapshot"
      ]
   }
}
```

The last part, `"state"` field will show the synced state, the "Synced!" means you watcher is synced with network.
