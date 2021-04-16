# cloud-tools-image [![Docker Repository on Quay](https://quay.io/repository/crowdstrike/cloud-tools-image/status "Docker Repository on Quay")](https://quay.io/repository/crowdstrike/cloud-tools-image)

```
docker run --privileged=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.aws:/root/.aws:ro -it --rm \
    -v ~/.config/gcloud:/root/.config/gcloud \
    -v ~/.azure:/root/.azure \
    -e FALCON_CLIENT_ID="$FALCON_CLIENT_ID" \
    -e FALCON_CLIENT_SECRET="$FALCON_CLIENT_SECRET" \
    -e CID="$CID" \
    quay.io/crowdstrike/cloud-tools-image
```

Cloud-tools-image is a collection of command-line tools for remote communication with public and private cloud environments.

Cloud-tools-image is an open source project, not CrowdStrike product. As such it carries no formal support, expressed or implied.

This container contains following command-line tools:
 * falcon_sensor_download command
 * falcon-node-sensor-build command
 * aws command
 * eksctl command
 * kubectl command
 * docker command
 * docker-credential-ecr-login helper (configured)
 * gcloud command
 * az command
 * helm command
