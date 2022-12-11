# PowerShell

$ErrorActionPreference = "Stop"

$IMAGE_NAME = Get-Content docker/image_name.txt
# $IMAGE_TAG = Get-Content appendix/latest_version.txt
$IMAGE_TAG = 'latest'
$DOCKER_IMAGE = $IMAGE_NAME+':'+$IMAGE_TAG

docker tag $DOCKER_IMAGE $DOCKER_IMAGE
docker login
docker push $DOCKER_IMAGE