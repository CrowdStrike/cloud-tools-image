# falcon-demo-container [![Docker Repository on Quay](https://quay.io/repository/slukasik/falcon-demo/status "Docker Repository on Quay")](https://quay.io/repository/slukasik/falcon-demo)

```
docker run --privileged=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ~/.aws:/root/.aws:ro -it --rm \
    quay.io/slukasik/falcon-demo
 ```

This container contains command-line tools to manipulate assets in AWS/ECS/EKS/Fargate environments.
 * aws command
 * eksctl command
 * kubectl command
 * docker command
 * docker-credential-ecr-login helper (set-up)
 * gcloud
