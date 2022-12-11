# PowerShell

$ErrorActionPreference = "Stop"

$IMAGE_NAME = Get-Content docker/image_name.txt
$IMAGE_TAG = Get-Content appendix/latest_version.txt
$DOCKER_IMAGE = $IMAGE_NAME+':'+$IMAGE_TAG
$DOCKER_FILE = 'docker/Dockerfile'

docker build -f $DOCKER_FILE -t $DOCKER_IMAGE .