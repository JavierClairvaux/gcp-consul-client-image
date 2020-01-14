# gcp-consul-client-image
Consul template image for GCP build with packer, you can install wathever services you might need, replace the next with your own:
```Console
$PATH_TO_CREDENTIALS $PROJECT $ZONE $USER
```
To provision run:
```Console
~/provisioner $NODE_NAME $CONSUL_DC $ENCRYPT_KEY $SERVER_IP
```
