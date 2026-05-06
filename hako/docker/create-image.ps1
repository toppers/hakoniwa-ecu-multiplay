# PowerShell

$ErrorActionPreference = "Stop"

$IMAGE_NAME = Get-Content appendix/image_name.txt
$IMAGE_TAG = Get-Content appendix/latest_version.txt
$DOCKER_IMAGE = $IMAGE_NAME+':'+$IMAGE_TAG
$DOCKER_FILE = 'docker/Dockerfile'

docker build -f $DOCKER_FILE -t $DOCKER_IMAGE --build-arg HAKONIWA_VERSION=$IMAGE_TAG .