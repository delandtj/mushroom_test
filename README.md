## testing mycelium
This lill skrip will just start $NUMOFNS network namespaces in your LINUX box where you can SUDO (because I __know__ for a fact that you weren't root, of course), start a mycelium daemon in the main namespace and one in each NS.

### Usage :
```bash
source ./bigmush.sh
doit
```
will create and start a 50 node mycelium with one central

```bash
source ./bigmush
dropit
```
will kill with little mercy mycelium daemons and delete the namespaces

### logging
every namespace has an `xx.out` file that is stout and stderr
the `xx.bin` file is the namespace daemon's privkey.

### behaviour testing

1) verify if you can reach all mycelium namespaces
2) also when running another machine in your net, verify if it's automatically detected
3) 
